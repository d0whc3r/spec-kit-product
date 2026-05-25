# AGENTS.md

Behavioral guidelines to reduce common LLM coding mistakes. Merge with project-specific instructions as needed.

**Tradeoff:** These guidelines bias toward caution over speed. For trivial tasks, use judgment.

## 1. Think Before Coding

**Don't assume. Don't hide confusion. Surface tradeoffs.**

Before implementing:

- State your assumptions explicitly. If uncertain, ask.
- If multiple interpretations exist, present them - don't pick silently.
- If a simpler approach exists, say so. Push back when warranted.
- If something is unclear, stop. Name what's confusing. Ask.

## 2. Simplicity First

**Minimum code that solves the problem. Nothing speculative.**

- No features beyond what was asked.
- No abstractions for single-use code.
- No "flexibility" or "configurability" that wasn't requested.
- No error handling for impossible scenarios.
- If you write 200 lines and it could be 50, rewrite it.

Ask yourself: "Would a senior engineer say this is overcomplicated?" If yes, simplify.

## 3. Surgical Changes

**Touch only what you must. Clean up only your own mess.**

When editing existing code:

- Don't "improve" adjacent code, comments, or formatting.
- Don't refactor things that aren't broken.
- Match existing style, even if you'd do it differently.
- If you notice unrelated dead code, mention it - don't delete it.

When your changes create orphans:

- Remove imports/variables/functions that YOUR changes made unused.
- Don't remove pre-existing dead code unless asked.

The test: Every changed line should trace directly to the user's request.

## 4. Goal-Driven Execution

**Define success criteria. Loop until verified.**

Transform tasks into verifiable goals:

- "Add validation" → "Write tests for invalid inputs, then make them pass"
- "Fix the bug" → "Write a test that reproduces it, then make it pass"
- "Refactor X" → "Ensure tests pass before and after"

For multi-step tasks, state a brief plan:

```
1. [Step] → verify: [check]
2. [Step] → verify: [check]
3. [Step] → verify: [check]
```

Strong success criteria let you loop independently. Weak criteria ("make it work") require constant clarification.

---

**These guidelines are working if:** fewer unnecessary changes in diffs, fewer rewrites due to overcomplication, and clarifying questions come before implementation rather than after mistakes.

<!-- SPECKIT START -->

For additional context about technologies to be used, project structure,
shell commands, and other important information, read the current plan

<!-- SPECKIT END -->

## Agent Boundaries

This repository ships a Spec Kit extension whose command surface is mirrored
across multiple AI coding agents. Every public command must exist in all four
integration surfaces (constitution §V).

| Agent          | Skill / Prompt Surface                                                | Manifest                                      |
| -------------- | --------------------------------------------------------------------- | --------------------------------------------- |
| Claude Code    | `.claude/skills/<skill-slug>/SKILL.md`                                | `.specify/integrations/claude.manifest.json`  |
| GitHub Copilot | `.github/agents/<name>.agent.md` + `.github/prompts/<name>.prompt.md` | `.specify/integrations/copilot.manifest.json` |
| OpenAI Codex   | manifest-only (no per-skill file)                                     | `.specify/integrations/codex.manifest.json`   |
| Spec Kit core  | `commands/speckit.<area>.<verb>.md` (canonical)                       | `.specify/integrations/speckit.manifest.json` |

Rules:

1. Canonical command file lives at `commands/speckit.<area>.<verb>.md`. Mirrors derive from it; they must not diverge in intent.
2. Adding a command requires updating: the canonical file, all four manifests, every mirror surface, `extension.yml` `provides.commands`, and `catalog.json` `provides.commands` count.
3. Renaming or removing a command is a breaking change and requires a `feat!:` or `BREAKING CHANGE:` commit per constitution §Governance.
4. The brownfield extension at `.specify/extensions/brownfield/` follows the same mirror rule via its own commands and the agent surfaces under `.claude/skills/speckit-brownfield-*` and `.github/agents/speckit.brownfield.*`.
5. All agents must emit output obeying constitution §III: no em dashes, plain English, PRFAQ + JTBD + Gherkin + Lean PRD conventions, `[NEEDS CLARIFICATION]` markers preserved.

<!-- CODEGRAPH_START -->

## CodeGraph

This project has a CodeGraph MCP server (`codegraph_*` tools) configured. CodeGraph is a tree-sitter-parsed knowledge graph of every symbol, edge, and file. Reads are sub-millisecond and return structural information grep cannot.

### When to prefer codegraph over native search

Use codegraph for **structural** questions — what calls what, what would break, where is X defined, what is X's signature. Use native grep/read only for **literal text** queries (string contents, comments, log messages) or after you already have a specific file open.

| Question                                                       | Tool                                         |
| -------------------------------------------------------------- | -------------------------------------------- |
| "How does X work? / trace X / explain a system / architecture" | `codegraph_explore` (seed with symbol names) |
| "Where is X defined?" / "Find symbol named X"                  | `codegraph_search`                           |
| "What calls function Y?"                                       | `codegraph_callers`                          |
| "What does Y call?"                                            | `codegraph_callees`                          |
| "What would break if I changed Z?"                             | `codegraph_impact`                           |
| "Show me Y's signature / source / docstring"                   | `codegraph_node`                             |
| "Give me focused context for a task/area"                      | `codegraph_context`                          |
| "What files exist under path/"                                 | `codegraph_files`                            |
| "Is the index healthy?"                                        | `codegraph_status`                           |

### Rules of thumb

- **`codegraph_explore` is the workhorse for understanding questions** ("how does X work", "trace…", "explain the Y system"). Feed it the key symbol/file names and read its output (line-numbered source from many files in one call). If the question names nothing concrete, do one quick `codegraph_search`/`codegraph_context` to surface the names, then explore with them. Fill gaps with `codegraph_node`/Read — don't grep-and-read your way through; that's the loop explore replaces.
- **Delegating exploration to a subagent?** Tell it to call `codegraph_explore` first and trust the result. A generic "explore"-style agent defaults to grep+Read and treats codegraph as just a search index, throwing away the token savings.
- **Trust codegraph results.** They come from a full AST parse. Do NOT re-verify them with grep — that's slower, less accurate, and wastes context.
- **Don't grep first** when looking up a symbol by name. `codegraph_search` is faster and returns kind + location + signature in one call.
- **Index lag**: the file watcher debounces ~500ms behind writes; don't re-query immediately after editing a file in the same turn.

### If `.codegraph/` doesn't exist

The MCP server returns "not initialized." Ask the user: _"I notice this project doesn't have CodeGraph initialized. Want me to run `codegraph init -i` to build the index?"_

<!-- CODEGRAPH_END -->
