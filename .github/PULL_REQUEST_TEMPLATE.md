<!-- Thanks for contributing. Fill in every section. PRs that skip the checklist will be sent back. -->

## Summary

<!-- One paragraph. What does this change and why. Frame in terms of the user-visible effect, not the implementation. -->

## Type of change

- [ ] Bug fix (`fix:`)
- [ ] New feature, non-breaking (`feat:`)
- [ ] Breaking change (`feat!:` or `BREAKING CHANGE:` footer)
- [ ] Documentation only (`docs:`)
- [ ] Internal refactor or chore (`refactor:` / `chore:`)
- [ ] CI or release tooling (`ci:` / `build:`)

## Scope

<!-- Tick everything this PR touches. -->

- [ ] Canonical command file in `commands/`
- [ ] Claude skill in `.claude/skills/`
- [ ] Copilot agent or prompt in `.github/agents/` or `.github/prompts/`
- [ ] Spec Kit manifest in `.specify/integrations/`
- [ ] `extension.yml` or `catalog.json`
- [ ] Templates in `templates/`
- [ ] Scripts in `.github/scripts/`
- [ ] Documentation only

## Constitution and agent-boundary checklist

<!-- All command-level changes must mirror across every agent surface. See AGENTS.md and the constitution §V. -->

- [ ] Canonical file in `commands/` is the source of truth.
- [ ] All four agent surfaces (Claude, Copilot, Codex, Spec Kit core) are updated or unaffected.
- [ ] `extension.yml` `provides.commands` matches the canonical command set.
- [ ] `catalog.json` `provides.commands` count matches.
- [ ] Generated artifact style obeys constitution §III: plain English, no em dashes, PRFAQ/JTBD/Gherkin/Lean PRD conventions preserved, `[NEEDS CLARIFICATION]` markers untouched.

## Verification

<!-- Show your work. Paste output, screenshots of generated artifacts, or before/after diffs. -->

- [ ] `pnpm run lint` passes (or N/A)
- [ ] `pnpm run validate` passes
- [ ] `pnpm run lint:content` passes
- [ ] I ran the affected command against a real `spec.md`/`plan.md` and inspected the output.

```
<paste relevant output here>
```

## Linked issues

<!-- "Closes #123", "Refs #456". -->

## Notes for reviewers

<!-- Anything that does not fit above: tradeoffs you considered, follow-ups you deferred, areas where you want a second opinion. -->
