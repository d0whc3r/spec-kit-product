// Product Spec Extension landing page. Progressive enhancement only: the page
// is fully readable and usable without JavaScript. No external dependencies.

(function () {
  "use strict";

  // --- Mobile navigation toggle ---------------------------------------------
  var toggle = document.querySelector(".nav-toggle");
  var links = document.getElementById("nav-links");

  if (toggle && links) {
    toggle.addEventListener("click", function () {
      var open = links.classList.toggle("open");
      toggle.setAttribute("aria-expanded", String(open));
    });

    // Close the menu after following an in-page link.
    links.addEventListener("click", function (event) {
      if (event.target.closest("a")) {
        links.classList.remove("open");
        toggle.setAttribute("aria-expanded", "false");
      }
    });
  }

  // --- Copy-to-clipboard: one button per <pre data-copy> --------------------
  // The button is injected so the markup stays clean and works without JS.
  document.querySelectorAll("pre[data-copy]").forEach(function (pre) {
    var wrap = document.createElement("div");
    wrap.className = "pre-wrap";
    pre.parentNode.insertBefore(wrap, pre);
    wrap.appendChild(pre);

    var btn = document.createElement("button");
    btn.type = "button";
    btn.className = "pre-copy";
    btn.textContent = "Copy";
    btn.setAttribute("aria-label", "Copy code to clipboard");
    wrap.appendChild(btn);

    btn.addEventListener("click", function () {
      var code = pre.querySelector("code");
      var text = (code ? code.innerText : pre.innerText) || "";

      var done = function () {
        btn.textContent = "Copied";
        btn.classList.add("is-copied");
        setTimeout(function () {
          btn.textContent = "Copy";
          btn.classList.remove("is-copied");
        }, 1500);
      };

      if (navigator.clipboard && navigator.clipboard.writeText) {
        navigator.clipboard.writeText(text).then(done, done);
      } else {
        done();
      }
    });
  });

  // --- Tabs (install methods, example outputs) ------------------------------
  // Each tab carries aria-controls pointing at its panel. Tabs in the same
  // [role="tablist"] form one group; activating one hides its siblings.
  document.querySelectorAll('[role="tablist"]').forEach(function (list) {
    var tabs = Array.prototype.slice.call(list.querySelectorAll('[role="tab"]'));

    var panelFor = function (tab) {
      return document.getElementById(tab.getAttribute("aria-controls"));
    };

    var activate = function (tab) {
      tabs.forEach(function (t) {
        var selected = t === tab;
        t.classList.toggle("is-active", selected);
        t.setAttribute("aria-selected", String(selected));
        var panel = panelFor(t);
        if (panel) {
          panel.classList.toggle("is-active", selected);
          if (selected) {
            panel.removeAttribute("hidden");
          } else {
            panel.setAttribute("hidden", "");
          }
        }
      });
    };

    list.addEventListener("click", function (event) {
      var tab = event.target.closest('[role="tab"]');
      if (tab) {
        activate(tab);
      }
    });

    // Left/right arrow keys move between tabs, matching the ARIA pattern.
    list.addEventListener("keydown", function (event) {
      var current = tabs.indexOf(document.activeElement);
      if (current === -1) {
        return;
      }
      var next = null;
      if (event.key === "ArrowRight") {
        next = tabs[(current + 1) % tabs.length];
      } else if (event.key === "ArrowLeft") {
        next = tabs[(current - 1 + tabs.length) % tabs.length];
      }
      if (next) {
        event.preventDefault();
        next.focus();
        activate(next);
      }
    });
  });

  // --- Markdown rendering (example excerpts + full-file viewer) --------------
  // `marked` is loaded from a CDN just before this script. If it failed to
  // load, excerpts stay as their plain-text <pre> fallback and the viewer
  // buttons degrade to opening the file on GitHub.
  var hasMarked = typeof window.marked !== "undefined";
  var GH_BLOB = "https://github.com/d0whc3r/spec-kit-product/blob/main/";

  if (hasMarked && window.marked.setOptions) {
    window.marked.setOptions({ gfm: true, breaks: false });
  }

  var render = function (text) {
    return window.marked.parse(text);
  };

  // --- Mermaid (lazy-loaded) ------------------------------------------------
  // The 2.5 MB library is fetched only the first time a rendered document
  // actually contains a ```mermaid block, so it never weighs on a plain visit.
  var MERMAID_SRC = "https://cdn.jsdelivr.net/npm/mermaid@11.4.1/dist/mermaid.min.js";
  var MERMAID_SRI = "sha384-rbtjAdnIQE/aQJGEgXrVUlMibdfTSa4PQju4HDhN3sR2PmaKFzhEafuePsl9H/9I";
  var mermaidPromise = null;
  var mermaidSeq = 0;

  var ensureMermaid = function () {
    if (mermaidPromise) {
      return mermaidPromise;
    }
    mermaidPromise = new Promise(function (resolve, reject) {
      var s = document.createElement("script");
      s.src = MERMAID_SRC;
      s.integrity = MERMAID_SRI;
      s.crossOrigin = "anonymous";
      s.referrerPolicy = "no-referrer";
      s.onload = function () {
        var dark = !window.matchMedia("(prefers-color-scheme: light)").matches;
        window.mermaid.initialize({
          startOnLoad: false,
          securityLevel: "strict",
          theme: dark ? "dark" : "default",
        });
        resolve(window.mermaid);
      };
      s.onerror = function () {
        reject(new Error("mermaid failed to load"));
      };
      document.head.appendChild(s);
    });
    return mermaidPromise;
  };

  // Attach pan/zoom controls to a rendered mermaid figure. The +/- buttons zoom
  // from the diagram's centre; Ctrl/Cmd + wheel zooms toward the pointer (plain
  // wheel still scrolls the page); drag pans once zoomed in. Reset returns to
  // the fit-to-width view.
  var setupMermaidZoom = function (fig) {
    var svg = fig.querySelector("svg");
    if (!svg) {
      return;
    }

    var MIN = 1;
    var MAX = 6;
    var scale = 1;
    var tx = 0;
    var ty = 0;

    // Mermaid sets an inline max-width to the diagram's natural width, which can
    // overflow the container. Pin it to the container so the rest state fits and
    // zoom scales up from a fit-to-width baseline.
    svg.style.maxWidth = "100%";
    svg.style.transformOrigin = "0 0";
    svg.style.transition = "transform 0.08s ease-out";

    // Keep at least a sliver of the diagram inside the viewport after panning.
    var clampPan = function () {
      var f = fig.getBoundingClientRect();
      var r = svg.getBoundingClientRect();
      var margin = 48;
      if (r.right < f.left + margin) {
        tx += f.left + margin - r.right;
      }
      if (r.left > f.right - margin) {
        tx -= r.left - (f.right - margin);
      }
      if (r.bottom < f.top + margin) {
        ty += f.top + margin - r.bottom;
      }
      if (r.top > f.bottom - margin) {
        ty -= r.top - (f.bottom - margin);
      }
    };

    var apply = function () {
      svg.style.transform = "translate(" + tx + "px," + ty + "px) scale(" + scale + ")";
      fig.classList.toggle("is-zoomed", scale > 1.001);
    };

    // Zoom by `factor`, anchoring the client point (mx,my) so it stays put.
    var zoomAt = function (factor, mx, my) {
      var next = Math.min(MAX, Math.max(MIN, scale * factor));
      if (next === scale) {
        return;
      }
      var rect = svg.getBoundingClientRect();
      var ratio = next / scale;
      tx -= (mx - rect.left) * (ratio - 1);
      ty -= (my - rect.top) * (ratio - 1);
      scale = next;
      clampPan();
      apply();
    };

    var zoomCentre = function (factor) {
      var f = fig.getBoundingClientRect();
      zoomAt(factor, f.left + f.width / 2, f.top + f.height / 2);
    };

    var reset = function () {
      scale = 1;
      tx = 0;
      ty = 0;
      apply();
    };

    var bar = document.createElement("div");
    bar.className = "mermaid-zoom";
    var addBtn = function (label, title, fn) {
      var b = document.createElement("button");
      b.type = "button";
      b.className = "mermaid-zoom-btn";
      b.textContent = label;
      b.title = title;
      b.setAttribute("aria-label", title);
      b.addEventListener("click", fn);
      bar.appendChild(b);
    };
    addBtn("−", "Zoom out", function () {
      zoomCentre(1 / 1.3);
    });
    addBtn("↺", "Reset zoom", reset);
    addBtn("+", "Zoom in", function () {
      zoomCentre(1.3);
    });
    fig.appendChild(bar);

    fig.addEventListener(
      "wheel",
      function (event) {
        if (!event.ctrlKey && !event.metaKey) {
          return;
        }
        event.preventDefault();
        zoomAt(event.deltaY < 0 ? 1.12 : 1 / 1.12, event.clientX, event.clientY);
      },
      { passive: false },
    );

    // Drag to pan, but only once zoomed in.
    var dragging = false;
    var lastX = 0;
    var lastY = 0;

    fig.addEventListener("pointerdown", function (event) {
      if (scale <= 1.001 || event.button !== 0) {
        return;
      }
      if (event.target.closest(".mermaid-zoom")) {
        return;
      }
      dragging = true;
      lastX = event.clientX;
      lastY = event.clientY;
      fig.classList.add("is-panning");
      svg.style.transition = "none";
      if (fig.setPointerCapture) {
        fig.setPointerCapture(event.pointerId);
      }
    });

    fig.addEventListener("pointermove", function (event) {
      if (!dragging) {
        return;
      }
      tx += event.clientX - lastX;
      ty += event.clientY - lastY;
      lastX = event.clientX;
      lastY = event.clientY;
      clampPan();
      apply();
    });

    var endDrag = function (event) {
      if (!dragging) {
        return;
      }
      dragging = false;
      fig.classList.remove("is-panning");
      svg.style.transition = "transform 0.08s ease-out";
      if (fig.releasePointerCapture && event.pointerId != null) {
        try {
          fig.releasePointerCapture(event.pointerId);
        } catch (err) {
          /* pointer already released */
        }
      }
    };
    fig.addEventListener("pointerup", endDrag);
    fig.addEventListener("pointercancel", endDrag);
  };

  // Replace each rendered ```mermaid code block in `root` with an SVG diagram.
  // On any failure the original code block is left untouched.
  var renderMermaid = function (root) {
    var blocks = root.querySelectorAll("pre > code.language-mermaid");
    if (!blocks.length) {
      return;
    }
    ensureMermaid()
      .then(function (mermaid) {
        blocks.forEach(function (code) {
          var pre = code.parentNode;
          if (!pre || pre.dataset.mermaidDone) {
            return;
          }
          pre.dataset.mermaidDone = "1";
          var id = "mmd-" + mermaidSeq++;
          mermaid
            .render(id, code.textContent || "")
            .then(function (out) {
              var fig = document.createElement("div");
              fig.className = "mermaid-rendered";
              fig.innerHTML = out.svg;
              pre.parentNode.replaceChild(fig, pre);
              setupMermaidZoom(fig);
            })
            .catch(function () {
              /* leave the fenced code block as-is */
            });
        });
      })
      .catch(function () {
        /* mermaid unavailable: code blocks stay as plain text */
      });
  };

  // Upgrade each excerpt <pre class="md-source"> to rendered markdown.
  if (hasMarked) {
    document.querySelectorAll("pre.md-source").forEach(function (pre) {
      var code = pre.querySelector("code");
      var raw = (code ? code.textContent : pre.textContent) || "";
      var view = document.createElement("div");
      view.className = "md-body md-excerpt";
      view.innerHTML = render(raw);
      pre.parentNode.insertBefore(view, pre);
      pre.hidden = true;
      renderMermaid(view);
    });
  }

  // Full-file viewer modal.
  var modal = document.getElementById("md-modal");
  var modalBody = document.getElementById("md-modal-body");
  var modalTitle = document.getElementById("md-modal-title");
  var modalGh = document.getElementById("md-modal-gh");
  var lastFocused = null;
  var cache = {};

  var closeModal = function () {
    if (!modal) {
      return;
    }
    modal.hidden = true;
    document.body.classList.remove("md-modal-open");
    if (lastFocused && lastFocused.focus) {
      lastFocused.focus();
    }
  };

  var openModal = function (path, title) {
    if (!modal) {
      return;
    }
    lastFocused = document.activeElement;
    modalTitle.textContent = title || path;
    modalGh.href = GH_BLOB + path;
    modal.hidden = false;
    document.body.classList.add("md-modal-open");
    modalBody.focus();

    var show = function (html) {
      modalBody.innerHTML = html;
      modalBody.scrollTop = 0;
      renderMermaid(modalBody);
    };

    if (cache[path]) {
      show(cache[path]);
      return;
    }

    show('<p class="md-loading">Loading&hellip;</p>');
    fetch(path)
      .then(function (res) {
        if (!res.ok) {
          throw new Error(String(res.status));
        }
        return res.text();
      })
      .then(function (text) {
        cache[path] = render(text);
        show(cache[path]);
      })
      .catch(function () {
        modalBody.innerHTML =
          '<p class="md-loading">Could not load this file. ' +
          '<a href="' +
          GH_BLOB +
          path +
          '" target="_blank" rel="noopener">Open it on GitHub</a> instead.</p>';
      });
  };

  document.querySelectorAll(".md-full-btn").forEach(function (btn) {
    btn.addEventListener("click", function () {
      var path = btn.getAttribute("data-md-full");
      var title = btn.getAttribute("data-md-title");
      if (!path) {
        return;
      }
      // No renderer available: send the user straight to the source.
      if (!hasMarked) {
        window.open(GH_BLOB + path, "_blank", "noopener");
        return;
      }
      openModal(path, title);
    });
  });

  if (modal) {
    modal.addEventListener("click", function (event) {
      if (event.target.closest("[data-md-close]")) {
        closeModal();
      }
    });
    document.addEventListener("keydown", function (event) {
      if (event.key === "Escape" && !modal.hidden) {
        closeModal();
      }
    });
  }
})();
