// Pipeline gate: validate an extension root's extension.yml.
//
// Asserts:
//   - schema_version present
//   - extension.id === "product"
//   - extension.version present, and equals the release version on a tag run
//     (RELEASE_VERSION env, or a refs/tags/v* GITHUB_REF)
//   - all required runtime files exist and are non-empty
//
// Usage:
//   node validate-manifest.mjs                 # validate the repo root
//   node validate-manifest.mjs --root <path>   # validate another root (an
//                                              # unpacked zip, say)

import path from "node:path";
import { fs, YAML, argv } from "zx";
import { repoRoot, isMain } from "./lib/repo.mjs";
import { logger } from "./lib/log.mjs";

const log = logger("validate-manifest");

// CHANGELOG.md lives at the repo root for release notes but is excluded from
// the zip, so it is not required here.
const REQUIRED = [
  "extension.yml",
  "README.md",
  "LICENSE",
  "commands/speckit.product.spec.md",
  "commands/speckit.product.info.md",
  "commands/speckit.product.plan.md",
  "commands/speckit.product.design.md",
  "templates/product-spec-template.md",
  "templates/product-checklist-template.md",
  "templates/product-info-template.md",
  "templates/product-plan-template.md",
  "templates/product-design-template.md",
];

// Returns true on success, false on any failure (logging each problem).
export function validateManifest({ root = repoRoot } = {}) {
  const manifestPath = path.join(root, "extension.yml");
  if (!fs.existsSync(manifestPath)) {
    log.fail(`${manifestPath} not found`);
    return false;
  }

  const manifest = YAML.parse(fs.readFileSync(manifestPath, "utf8"));
  let ok = true;

  if (!manifest.schema_version) {
    log.fail("schema_version missing");
    ok = false;
  }

  const id = manifest.extension?.id;
  if (id !== "product") {
    log.fail(`extension.id must be "product", got "${id ?? ""}"`);
    ok = false;
  }

  const version = manifest.extension?.version;
  if (!version) {
    log.fail("extension.version missing");
    ok = false;
  }

  // Tag/version equality — only when an explicit version is provided or the
  // workflow runs from a version tag. RELEASE_VERSION is used where
  // GITHUB_REF_NAME (a GitHub Actions built-in) cannot be overridden.
  const ref = process.env.RELEASE_VERSION || process.env.GITHUB_REF_NAME || "";
  const isTagRun =
    Boolean(process.env.RELEASE_VERSION) ||
    (process.env.GITHUB_REF || "").startsWith("refs/tags/v");
  if (isTagRun && version) {
    const expected = ref.replace(/^v/, "");
    if (version !== expected) {
      log.fail(`version mismatch: tag ${ref}, manifest ${version}`);
      ok = false;
    }
  }

  for (const rel of REQUIRED) {
    const file = path.join(root, rel);
    if (!fs.existsSync(file)) {
      log.fail(`required file missing: ${file}`);
      ok = false;
    } else if (fs.statSync(file).size === 0) {
      log.fail(`required file empty: ${file}`);
      ok = false;
    }
  }

  if (ok) log.ok(`id=${id} version=${version} root=${root}`);
  return ok;
}

if (isMain(import.meta.url)) {
  const root = argv.root ? path.resolve(argv.root) : repoRoot;
  if (!validateManifest({ root })) process.exit(1);
}
