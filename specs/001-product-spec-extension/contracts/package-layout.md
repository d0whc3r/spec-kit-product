# Contract: Release Package Layout

This contract pins the exact structure of the release zip that the pipeline produces and that `specify extension add ... --from <zip-url>` consumes. Any change to this layout is a breaking change and requires a major version bump.

## Zip Filename

`product-<version>.zip`, where `<version>` is the value from `extension.yml` (without any `v` prefix). Example: `product-1.0.0.zip`.

## Zip Root Contents (Required)

Every release zip must contain the following at the **top level** (no nesting, no `extension/` wrapper directory):

```text
product-<version>.zip/
├── extension.yml                      # Manifest. Version field must equal the git tag without the v prefix.
├── README.md                          # User and contributor install docs, invocation, source-of-truth contract.
├── LICENSE                            # License file. Required by the Spec Kit publishing guide.
├── CHANGELOG.md                       # Version history. Recommended by the publishing guide.
├── commands/
│   └── speckit.product.spec.md        # The slash command body.
├── templates/
│   ├── product-spec-template.md       # The canonical product spec template at runtime.
│   └── product-checklist-template.md  # The canonical quality checklist template at runtime.
└── scripts/                           # Optional. Present only if helper scripts are needed.
    ├── bash/
    │   └── *.sh
    └── powershell/
        └── *.ps1
```

## Required Validation (Pipeline Gate)

Before the zip is published, the pipeline MUST verify:

1. `extension.yml` exists at the zip root.
2. `extension.yml` parses as valid YAML.
3. `extension.yml` field `extension.version` equals the git tag with the leading `v` stripped.
4. `extension.yml` declares `extension.id == "product"`.
5. `README.md` exists at the zip root and is non-empty.
6. `LICENSE` exists at the zip root and is non-empty.
7. `commands/speckit.product.spec.md` exists.
8. `templates/product-spec-template.md` exists.
9. `templates/product-checklist-template.md` exists.
10. The zip contains no files outside the listed allowlist (no `.git`, no `specs/`, no `.github/`, no `node_modules`, no editor metadata).

If any check fails, the pipeline aborts and no release is published.

## What MUST NOT Be in the Zip

- The repo's `specs/` directory (design artifacts).
- The repo's `.github/workflows/` directory (CI configuration).
- The repo's `.specify/` directory (the dogfood install of the extension; it is a copy or symlink of the same content already at zip root).
- The repo's `catalog.json` (it is not part of the installed extension; it lives at the repo level for catalog resolution).
- Editor or VCS metadata: `.git/`, `.vscode/`, `.idea/`, `.DS_Store`.
- Any other file that is not part of the extension's runtime surface.

## Determinism

The zip MUST be byte-deterministic for a given input tree:

- File ordering inside the archive: alphabetical.
- File timestamps: fixed to the commit timestamp of the tag being released, not the build time. (Avoids spurious zip diffs across re-runs of the same tag.)
- No compression metadata leakage (no per-build user / hostname).

## Source of Truth in This Repo

The canonical source for what goes into the zip lives under `extension/` at the repository root. The pipeline zips that subtree and only that subtree. No other directory is included.
