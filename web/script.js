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
})();
