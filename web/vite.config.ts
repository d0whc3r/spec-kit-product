import { defineConfig } from "vite";

// The site is published to a GitHub Pages PROJECT path
// (https://d0whc3r.github.io/spec-kit-product/), so every emitted asset URL
// must be relative. base: "./" keeps the injected <script>/<link> tags
// relative and matches the runtime fetch() of the example markdown files,
// which resolve against the document URL.
export default defineConfig({
  base: "./",
  build: {
    outDir: "dist",
    emptyOutDir: true,
    target: "es2020",
  },
});
