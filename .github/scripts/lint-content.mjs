// Pipeline: lint extension content (markdown templates and command bodies).
//
// Per template:
//   - No em dash.
//   - Canonical mandatory headings present and in order.
//   - Optional headings (when present) appear after the mandatory ones and in
//     declared order. Optional headings may carry a " _(optional)_" suffix.
//   - The command file references the template and any extra refs.
//   - No banned AI-tell phrases.
// Then an oxfmt --check pass over commands, templates, and README.
//
// Usage: node lint-content.mjs

import path from "node:path";
import { $, fs } from "zx";
import { repoRoot, isMain } from "./lib/repo.mjs";
import { logger } from "./lib/log.mjs";

const log = logger("lint-content");

const BANNED_PHRASES = ["delve", "tapestry", "in essence", "navigate the landscape"];
const CHECKLIST = "templates/product-checklist-template.md";

// The humanization guide is the single source. Each command and prose template
// must reference it, and each command must copy the canonical AI-tell list
// verbatim (style rule + validation row). The string below is that list; keep
// it identical to "The enforced minimum" block in the guide.
const GUIDE = "templates/humanization-guide.md";
const CANONICAL_AITELLS =
  '"delve", "tapestry", "in essence", "navigate the landscape", "seamless", "intuitive", "leverage" (as a standalone verb), "robust" (without a measurable target), "it is worth noting", "it should be noted", "as previously mentioned"';

// Conditional headings that interleave between mandatory ones (e.g. plan's
// "Build Overview", design's "Data Design") are not listed here; they carry the
// _(optional)_ marker inline and are validated by the single ordered pass.
const TEMPLATES = [
  {
    template: "templates/product-spec-template.md",
    command: "commands/speckit.product.spec.md",
    mandatory: [
      "Headline",
      "Target Users and Personas",
      "Problem Statement (Job to Be Done)",
      "Value Proposition",
      "Scope",
      "Out of Scope",
      "Use Cases",
      "Success Metrics",
      "Risks and Open Product Questions",
    ],
    optional: [],
    extraRefs: [CHECKLIST],
  },
  {
    template: "templates/product-info-template.md",
    command: "commands/speckit.product.info.md",
    mandatory: ["Overview", "Headline", "What is Changing", "Out of Scope"],
    optional: ["Risks", "Key Decisions", "References"],
    extraRefs: [CHECKLIST],
  },
  {
    template: "templates/product-plan-template.md",
    command: "commands/speckit.product.plan.md",
    mandatory: ["Summary", "Feature Context", "Goals", "Out of Scope", "Delivery Phases"],
    optional: [
      "Key Decisions",
      "Risks and Mitigations",
      "Divergences and Edge Cases",
      "Validation",
      "Open Questions",
    ],
    extraRefs: [CHECKLIST],
  },
  {
    template: "templates/product-design-template.md",
    command: "commands/speckit.product.design.md",
    mandatory: [
      "Summary",
      "Technical Context",
      "Architectural Approach",
      "Affected Modules",
      "Testing Strategy",
      "Rollout and Migration",
    ],
    optional: ["Risks and Mitigations", "Open Questions"],
    extraRefs: [CHECKLIST],
  },
];

const read = (rel) => fs.readFileSync(path.join(repoRoot, rel), "utf8");
const exists = (rel) => fs.existsSync(path.join(repoRoot, rel));
const occurrences = (haystack, needle) => haystack.split(needle).length - 1;

// 1-based line of the first heading line, or 0 if absent.
function headingLine(lines, heading) {
  const idx = lines.findIndex((l) => l === `## ${heading}` || l === `## ${heading} _(optional)_`);
  return idx === -1 ? 0 : idx + 1;
}

function lintTemplate(spec, fail) {
  if (!exists(spec.template)) {
    fail(`${spec.template} missing`);
    return;
  }
  const text = read(spec.template);
  const lines = text.split("\n");

  if (text.includes("—")) fail(`em dash found in ${spec.template}`);

  // Single ordered cursor across mandatory then optional headings.
  let last = 0;
  const checkOrder = (headings, required) => {
    for (const h of headings) {
      const line = headingLine(lines, h);
      if (line === 0) {
        if (required) fail(`missing mandatory heading in ${spec.template}: ## ${h}`);
        continue;
      }
      if (line <= last) {
        fail(
          `heading out of canonical order in ${spec.template}: ## ${h} (line ${line}, previous at ${last})`,
        );
      }
      last = line;
    }
  };
  checkOrder(spec.mandatory, true);
  checkOrder(spec.optional, false);

  // Command file references.
  if (!exists(spec.command)) {
    fail(`${spec.command} missing`);
  } else {
    const cmd = read(spec.command);
    for (const ref of [spec.template, ...spec.extraRefs]) {
      if (!cmd.includes(ref)) fail(`${spec.command} does not reference ${ref}`);
    }
  }

  for (const phrase of BANNED_PHRASES) {
    if (text.toLowerCase().includes(phrase)) {
      fail(`banned phrase "${phrase}" found in ${spec.template}`);
    }
  }
}

// The humanization guide is the single source of the AI-tell practice. Enforce
// that the guide carries the canonical list, that every command and prose
// template references the guide, and that each command copies the list verbatim
// in both places (style rule + validation row) and uses no em dash of its own.
function lintHumanization(fail) {
  if (!exists(GUIDE)) {
    fail(`${GUIDE} missing`);
    return;
  }
  const guide = read(GUIDE);
  if (guide.includes("—")) fail(`em dash found in ${GUIDE}`);
  if (!guide.includes(CANONICAL_AITELLS)) {
    fail(`${GUIDE} is missing the canonical AI-tell list ("The enforced minimum" drifted)`);
  }

  for (const spec of TEMPLATES) {
    if (exists(spec.template) && !read(spec.template).includes(GUIDE)) {
      fail(`${spec.template} does not reference ${GUIDE}`);
    }
    if (!exists(spec.command)) continue;
    const cmd = read(spec.command);
    if (!cmd.includes(GUIDE)) fail(`${spec.command} does not reference ${GUIDE}`);
    const n = occurrences(cmd, CANONICAL_AITELLS);
    if (n < 2) {
      fail(
        `${spec.command} must copy the canonical AI-tell list verbatim in the style rule and the validation row (found ${n}/2)`,
      );
    }
    if (cmd.includes(" — ")) fail(`em dash found in ${spec.command}`);
  }
}

export async function lintContent() {
  let failed = false;
  const fail = (msg) => {
    log.fail(msg);
    failed = true;
  };

  for (const spec of TEMPLATES) lintTemplate(spec, fail);
  lintHumanization(fail);

  // oxfmt pass over the shipped markdown.
  const oxfmt = path.join(repoRoot, "node_modules/.bin/oxfmt");
  if (fs.existsSync(oxfmt)) {
    const res = await $({ cwd: repoRoot, nothrow: true })`${oxfmt} --check ${[
      "commands/**/*.md",
      "templates/**/*.md",
      "README.md",
    ]}`;
    if (res.exitCode !== 0) fail("oxfmt reported unformatted markdown files");
  }

  if (failed) return false;
  log.ok("content lint passed");
  return true;
}

if (isMain(import.meta.url)) {
  if (!(await lintContent())) process.exit(1);
}
