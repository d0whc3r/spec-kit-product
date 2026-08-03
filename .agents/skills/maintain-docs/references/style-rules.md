# Style Rules

Extracted from `.specify/memory/constitution.md` §III and
`docs/Style-Guide.md`. Apply to every wiki page and every root-level
markdown file. The lint script enforces the mechanical rules; the rest
are judgment calls but consistent across the repo.

## Mechanical rules (the lint enforces these)

1. **No em dash character.** The codepoint `U+2014` (`—`) is forbidden
   in `docs/` and root `*.md`. Use a hyphen, comma, parenthesis, or
   period instead. See `references/edit-patterns.md` §8 for examples.
2. **No en dash in prose.** `U+2013` (`–`) is fine in numeric ranges
   (`2024–2026`) but not in prose. Prefer a hyphen.
3. **English only.** No mixed-language pages. Code identifiers and
   command names are fine.
4. **Markdown links to local pages use `Page-Name.md`.** The same link
   must work on the rendered repo and on GitHub Wiki. Anchor links
   inside a page use lowercase, no punctuation: `#speckitproductbrief`.

## Voice rules (apply by hand)

1. **Plain English. Short sentences.** Prefer 15 words. Tolerate 25.
   Split anything longer.
2. **No marketing voice.** No "powerful", "seamless", "robust",
   "best-in-class", "delight", "unleash". Just describe what the
   extension does.
3. **Active voice over passive.** "The command writes `00-info.md`",
   not "`00-info.md` is written by the command".
4. **Imperative for instructions.** "Run `/speckit.product.brief`",
   not "You should run `/speckit.product.brief`".
5. **Concrete over abstract.** Use real paths, real filenames, real
   command outputs. Avoid placeholder phrasing like "the appropriate
   file".
6. **Tables for parallel structure.** When you list more than three
   parallel items with the same fields (name, reads, writes, audience),
   use a table.
7. **Code fences for code.** Bash in `bash` blocks, command lines in
   `text` blocks, JSON in `json` blocks. Specify the language; the
   wiki and the repo both render it.
8. **Backticks for symbols in prose.** Command names, file paths,
   environment variable names, error codes, and config keys all go in
   backticks.

## Conventions specific to this project

1. **Refer to commands with the leading slash.** `/speckit.product.brief`,
   not `speckit.product.brief` or `product.brief`. The slash makes the
   command shape clear and matches how a user invokes it.
2. **Refer to artifact files by their full name including the numeric
   prefix.** `00-info.md`, `10-spec.md`, `20-plan.md`, `30-design.md`.
   The prefixes carry meaning (reading order in the `product/`
   subfolder).
3. **Always distinguish `spec.md` (canonical, in `specs/<feature>/`)
   from `product/10-spec.md` (derived).** The wiki frequently uses both
   in the same paragraph. Be explicit.
4. **`[NEEDS CLARIFICATION]` markers are preserved literally.** They
   are uppercase, bracketed, and must round-trip through the wiki when
   shown in examples. Never silently resolve one.
5. **Use the phrase "host AI agent" or "host agent"** when referring
   to Claude Code, Copilot, Codex, or any Spec Kit-aware assistant
   running the command prompt. Avoid "AI", "LLM", or "the model" in
   prose.
6. **Use the phrase "the extension"** for the spec-kit-product
   extension itself. Avoid "the plugin", "the product", or "this tool".
7. **Capitalize Spec Kit as two words.** Lowercase `specify` only when
   it is literally the CLI binary name (in code blocks).
8. **Constitution references** are spelled as
   `.specify/memory/constitution.md` §III (or whichever section).
   Use the `§` symbol, not the word "Section".

## Conventions for tables

1. **Pad cells.** The repo's existing tables are padded so the columns
   align in plain text. Mimic the existing padding when adding rows;
   do not realign the whole table.
2. **Header column order is fixed.** The "Command / Reads / Writes /
   Audience" table appears in three files (`README.md`,
   `docs/Home.md`, `docs/Commands.md`). The columns are always in
   that order, and the rows are always in command-numeric order
   (brief, plan, design).
3. **Anchor links from the table use the section header form** with
   punctuation stripped: `/speckit.product.brief` →
   `#speckitproductbrief`.

## Headings

1. **One H1 per page**, matching the page title.
2. **Use sentence case for headings.** "Getting started", not
   "Getting Started" in body text. The page titles themselves are
   title-cased to match the filename convention used by GitHub Wiki
   (`Getting-Started.md` → "Getting Started" page title).
3. **No emoji in headings or body.** Use plain text. The wiki renders
   the same in repo and on GitHub Wiki, where emoji can break layout
   in `_Sidebar.md`.

## Code blocks

1. **Bash blocks** show what the user types. Do not include the shell
   prompt (`$`) unless distinguishing input from output.
2. **Output blocks** are `text`. Do not invent output. If you need to
   show fictional output, mark it (`# example output, your version
   may differ`).
3. **JSON / YAML blocks** are formatted to fit ~80 columns. If a real
   file exceeds that, show only the keys that matter for the point
   being made and elide the rest with `... `.

## What to avoid

1. Avoid "we" and "you" interchangeably in the same page. Pick one.
   `README.md` and `docs/Home.md` use "you" (addressing the reader).
   `docs/Architecture.md` is neutral and avoids both.
2. Avoid future tense for current behavior. "The command writes" not
   "The command will write".
3. Avoid hedging. "Probably", "might", "should" weaken instructions.
   If a behavior is conditional, name the condition.
4. Avoid links that depend on the rendered location. A link to
   `../README.md` works in the repo but not on GitHub Wiki. Use either
   an absolute URL (`https://github.com/...`) or a same-folder
   relative link (`Home.md`).
5. Avoid filenames in headings unless the page is specifically about
   the file. Mention the file in the first sentence of the section
   body instead.
