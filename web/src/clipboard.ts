// Copy-to-clipboard: one button per <pre data-copy>. The button is injected so
// the markup stays clean and works without JS.
export function setupClipboard(): void {
  document.querySelectorAll<HTMLPreElement>("pre[data-copy]").forEach((pre) => {
    const wrap = document.createElement("div");
    wrap.className = "pre-wrap";
    pre.parentNode!.insertBefore(wrap, pre);
    wrap.appendChild(pre);

    const btn = document.createElement("button");
    btn.type = "button";
    btn.className = "pre-copy";
    btn.textContent = "Copy";
    btn.setAttribute("aria-label", "Copy code to clipboard");
    wrap.appendChild(btn);

    btn.addEventListener("click", () => {
      const code = pre.querySelector("code");
      const text = (code ? code.innerText : pre.innerText) || "";

      const done = () => {
        btn.textContent = "Copied";
        btn.classList.add("is-copied");
        setTimeout(() => {
          btn.textContent = "Copy";
          btn.classList.remove("is-copied");
        }, 1500);
      };

      if (navigator.clipboard?.writeText) {
        navigator.clipboard.writeText(text).then(done, done);
      } else {
        done();
      }
    });
  });
}
