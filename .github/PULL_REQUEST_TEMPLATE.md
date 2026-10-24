<!-- Thanks for contributing. Fill in every section. PRs that skip the checklist will be sent back. -->

## Summary

<!-- One paragraph. What does this change and why. Frame in terms of the user-visible effect, not the implementation. -->

## Type of change

- [ ] Bug fix (`fix:`)
- [ ] New feature, non-breaking (`feat:`)
- [ ] Breaking change (`BREAKING CHANGE:` footer)
- [ ] Documentation only (`docs:`)
- [ ] Internal refactor or chore (`refactor:` / `chore:`)
- [ ] CI or release tooling (`ci:` / `build:`)

## Scope

<!-- Tick everything this PR touches. -->

- [ ] Command file in `commands/`
- [ ] Contributor skill in `.agents/skills/`
- [ ] `extension.yml` or `catalog.json`
- [ ] Templates in `templates/`
- [ ] Scripts in `.github/scripts/`
- [ ] Documentation only

## Command checklist

<!-- Spec Kit renders the files in `commands/` for each coding agent at install time. See AGENTS.md. -->

- [ ] `extension.yml` `provides.commands` matches the command files in `commands/`.
- [ ] `catalog.json` `provides` counts match `extension.yml`.
- [ ] Generated artifact style obeys `templates/humanization-guide.md`: plain English, no em dashes, PRFAQ/JTBD/Gherkin/Lean PRD conventions preserved, `[NEEDS CLARIFICATION]` markers untouched.

## Verification

<!-- Show your work. Paste output, screenshots of generated artifacts, or before/after diffs. -->

- [ ] `pnpm check` passes
- [ ] `pnpm web:build` passes (or N/A)
- [ ] I ran the affected command against a real `spec.md`/`plan.md` and inspected the output.

```
<paste relevant output here>
```

## Linked issues

<!-- "Closes #123", "Refs #456". -->

## Notes for reviewers

<!-- Anything that does not fit above: tradeoffs you considered, follow-ups you deferred, areas where you want a second opinion. -->
