#!/usr/bin/env bash
# Humanize detector for generated product docs.
# Read-only. Exits 0 always; prints advisory findings to stdout.
#
# Usage:
#   bash humanize_lint.sh [file.md ...]
# With no args, scans specs/*/product/*.md and examples/specs/*/product/*.md.
#
# Portable on macOS BSD grep: no grep -P, em dash matched as a literal char.
# Findings are advisory. A flag is a prompt to look, not proof of a problem;
# some words (robust, leverage) are tells only when used a certain way.

set -u

# Resolve targets.
if [[ $# -gt 0 ]]; then
  targets=("$@")
else
  # Only the four prose docs. checklist.md is a validation gate, not prose.
  targets=()
  for g in specs/*/product/{00-info,10-spec,20-plan,30-design}.md \
           examples/specs/*/product/{00-info,10-spec,20-plan,30-design}.md; do
    [[ -f "$g" ]] && targets+=("$g")
  done
fi

if [[ ${#targets[@]} -eq 0 ]]; then
  echo "no target files (pass paths, or run from repo root with product docs)" >&2
  exit 0
fi

issues=0
note() { echo "[tell] $*"; issues=$((issues + 1)); }

# Phrases that should simply be deleted or replaced. Multi-word entries are
# self-bounded; single words may over-match rare longer words (advisory).
BANNED='delve|tapestry|in essence|navigate the landscape|seamless|seamlessly'
BANNED+='|intuitive|leverage|leverages|leveraging|robust|it is worth noting'
BANNED+='|it should be noted|as previously mentioned|cutting-edge'
BANNED+='|state-of-the-art|game-changer|game changer|revolutionary|unleash'
BANNED+='|empower|empowers|empowering|at the end of the day|crucial|vital|essential'

# Essay connectives at the start of a line or sentence.
OPENERS='furthermore|moreover|additionally'

# Hedging filler that weakens a statement. Bare modals (may, might, could) are
# left out on purpose: a risk bullet is legitimately conditional, and flagging
# every "may" there is noise. These words are tells regardless of section.
HEDGES='perhaps|possibly|potentially|somewhat|in certain cases|in some cases'

for f in "${targets[@]}"; do
  [[ -f "$f" ]] || { echo "skip (not found): $f" >&2; continue; }

  # 1. em dash (literal U+2014). BSD grep matches the UTF-8 bytes directly.
  while IFS= read -r line; do
    note "em dash: $f:$line"
  done < <(grep -n '—' "$f" 2>/dev/null || true)

  # 2. banned AI-tell phrases (case-insensitive)
  while IFS= read -r line; do
    note "banned phrase: $f:$line"
  done < <(grep -niE "$BANNED" "$f" 2>/dev/null || true)

  # 3. essay connectives (only when they open a sentence)
  while IFS= read -r line; do
    note "formulaic opener: $f:$line"
  done < <(grep -niE "(^|[.!?] )($OPENERS)" "$f" 2>/dev/null || true)

  # 4. hedging
  while IFS= read -r line; do
    note "hedging: $f:$line"
  done < <(grep -niE "$HEDGES" "$f" 2>/dev/null || true)

  # 5. the "not just X, but/it's Y" inflation construction
  while IFS= read -r line; do
    note "inflation (not just X but Y): $f:$line"
  done < <(grep -niE "not just .*(but|it'?s)" "$f" 2>/dev/null || true)

  # 6. over-long sentences (>25 words). Splits a prose line into sentences first
  #    so a normal multi-sentence paragraph does not trip the check. Skips
  #    headings, bullets, tables, blockquotes, and fenced code.
  while IFS= read -r line; do
    note "long sentence (>25 words): $f:$line"
  done < <(awk '
    /^[[:space:]]*```/ { infence = !infence; next }
    infence { next }
    /^[[:space:]]*([#>|*-]| *$)/ { next }
    {
      s = split($0, sents, /[.!?]("|'"'"'|\))?[[:space:]]+/)
      for (i = 1; i <= s; i++) {
        n = split(sents[i], w, /[[:space:]]+/)
        if (n > 25) {
          snippet = sents[i]
          if (length(snippet) > 70) snippet = substr(snippet, 1, 67) "..."
          printf("%d: (%d words) %s\n", NR, n, snippet)
        }
      }
    }
  ' "$f" 2>/dev/null || true)

  # 7. three or more consecutive bullets that open with the same word
  while IFS= read -r line; do
    note "parallel bullet openers: $f:$line"
  done < <(awk '
    function flush() {
      if (run >= 3) printf("%d: %d bullets in a row open with \"%s\"\n", startln, run, word)
      run = 0; word = ""
    }
    /^[[:space:]]*[-*] \[[ xX]\]/ { flush(); next }
    /^[[:space:]]*[-*] / {
      line = $0
      sub(/^[[:space:]]*[-*][[:space:]]+/, "", line)
      n = split(line, w, /[[:space:]]+/)
      first = tolower(w[1])
      gsub(/[^a-z0-9]/, "", first)
      if (first == word && first != "") {
        run++
      } else {
        flush(); word = first; run = 1; startln = NR
      }
      next
    }
    { flush() }
    END { flush() }
  ' "$f" 2>/dev/null || true)
done

echo
if [[ $issues -eq 0 ]]; then
  echo "summary: 0 humanize findings across ${#targets[@]} file(s)."
else
  echo "summary: $issues humanize finding(s) across ${#targets[@]} file(s). Advisory; review each."
fi
exit 0
