// Ambient types for the two runtime dependencies loaded from a CDN as globals
// (see index.html). They are intentionally minimal: only the surface this site
// actually calls is typed.

interface MarkedLike {
  parse(src: string): string;
  setOptions?(options: { gfm?: boolean; breaks?: boolean }): void;
}

interface MermaidRenderResult {
  svg: string;
}

interface MermaidLike {
  initialize(config: { startOnLoad?: boolean; securityLevel?: string; theme?: string }): void;
  render(id: string, text: string): Promise<MermaidRenderResult>;
}

interface Window {
  marked?: MarkedLike;
  mermaid?: MermaidLike;
}
