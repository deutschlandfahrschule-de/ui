// Gemeinsames JavaScript der Deutschlandfahrschule-Oberflächen (dfs_ui).
// Funktioniert in LiveViews (Hooks) und in normalen Seiten (Delegation am Dokument).

const html = () => document.documentElement;

// Dialoge, die ein LiveView-Hook steuert; die Delegation unten lässt sie in Ruhe.
// (Kein DOM-Attribut, weil LiveView Attribute beim Patch zurücksetzt.)
const liveDialogs = new WeakSet();

function setSidebar(collapsed) {
  if (collapsed) html().setAttribute("data-sidebar", "collapsed");
  else html().removeAttribute("data-sidebar");
  try {
    localStorage.setItem("dfs:sidebar", collapsed ? "collapsed" : "expanded");
  } catch (_e) {}
}

function closeMenus(except) {
  document.querySelectorAll("details.dfs-menu[open]").forEach((d) => {
    if (d !== except) d.removeAttribute("open");
  });
}

let initialized = false;

/** Richtet Sidebar, mobiles Menü, Dialoge in normalen Seiten und Aufklappmenüs ein (einmalig). */
export function initDfsUi() {
  if (initialized) return;
  initialized = true;

  document.addEventListener("click", (event) => {
    const target = event.target instanceof Element ? event.target : null;
    if (!target) return;

    if (target.closest("[data-sidebar-toggle]")) {
      setSidebar(html().getAttribute("data-sidebar") !== "collapsed");
      return;
    }
    if (target.closest("[data-nav-toggle]")) {
      html().toggleAttribute("data-nav");
      if (html().hasAttribute("data-nav")) html().setAttribute("data-nav", "open");
      return;
    }
    if (target.closest("[data-nav-close]")) {
      html().removeAttribute("data-nav");
      return;
    }

    const opener = target.closest("[data-dialog-open]");
    if (opener) {
      const dialog = document.getElementById(opener.getAttribute("data-dialog-open"));
      if (dialog && !dialog.open && !liveDialogs.has(dialog)) dialog.showModal();
      return;
    }
    const closer = target.closest("[data-dialog-close]");
    if (closer) {
      const dialog = closer.closest("dialog");
      if (dialog && dialog.open && !liveDialogs.has(dialog)) dialog.close();
      return;
    }
    if (target.closest("[data-dismiss]")) {
      const box = target.closest("[role='alert'], [role='status']");
      if (box && !box.closest("[data-phx-main], [data-phx-session]")) box.remove();
    }

    // Aufklappmenüs: nur eines offen, Klick außerhalb oder auf einen Menüpunkt schließt.
    const menu = target.closest("details.dfs-menu");
    if (menu) {
      if (target.closest("[role='menuitem']")) menu.removeAttribute("open");
      closeMenus(menu);
    } else {
      closeMenus(null);
    }
  });

  document.addEventListener("keydown", (event) => {
    if (event.key === "Escape") {
      closeMenus(null);
      html().removeAttribute("data-nav");
    }
  });

  // Dialoge ohne Hook: Klick auf den Hintergrund schließt.
  document.addEventListener("click", (event) => {
    const dialog = event.target;
    if (dialog instanceof HTMLDialogElement && dialog.open && !liveDialogs.has(dialog)) {
      const rect = dialog.getBoundingClientRect();
      const inside =
        event.clientX >= rect.left && event.clientX <= rect.right &&
        event.clientY >= rect.top && event.clientY <= rect.bottom;
      if (!inside) dialog.close();
    }
  });

  // Nach einer LiveView-Navigation das mobile Menü schließen.
  window.addEventListener("phx:page-loading-stop", () => html().removeAttribute("data-nav"));
}

/**
 * DOM-Callback für die LiveSocket (`dom: dfsUiDom`): bewahrt beim Patch den Browser-Zustand
 * `open` von <dialog> und <details>. Ohne ihn entfernt LiveView das Attribut, ein modaler
 * Dialog bliebe dann unsichtbar im Top-Layer und blockiert alle Klicks.
 */
export const dfsUiDom = {
  onBeforeElUpdated(from, to) {
    if ((from.tagName === "DIALOG" || from.tagName === "DETAILS") && from.open && !to.hasAttribute("open")) {
      to.setAttribute("open", "");
    }
    return true;
  },
};

/** Dialog-Hook: der Server besitzt den Zustand (data-open), der Browser ruft showModal()/close(). */
const DfsUiDialog = {
  mounted() {
    liveDialogs.add(this.el);
    this.shown = false;
    this.sync();
    this.el.addEventListener("cancel", (event) => {
      event.preventDefault();
      this.requestClose();
    });
    this.el.addEventListener("click", (event) => {
      if (event.target !== this.el) return;
      const rect = this.el.getBoundingClientRect();
      const inside =
        event.clientX >= rect.left && event.clientX <= rect.right &&
        event.clientY >= rect.top && event.clientY <= rect.bottom;
      if (!inside) this.requestClose();
    });
  },
  updated() {
    this.sync();
  },
  destroyed() {
    this.closeModal();
  },
  sync() {
    const wanted = this.el.dataset.open === "true";
    if (wanted && !this.el.open) {
      this.el.showModal();
      this.shown = true;
    }
    if (!wanted && (this.el.open || this.shown)) this.closeModal();
  },
  // close() wirkt nur mit gesetztem open-Attribut; sonst bliebe der Dialog im Top-Layer.
  closeModal() {
    if (!this.el.hasAttribute("open")) this.el.setAttribute("open", "");
    this.el.close();
    this.shown = false;
  },
  requestClose() {
    const event = this.el.dataset.onClose || "close_dialog";
    const payload = { id: this.el.id };
    if (this.el.getAttribute("phx-target")) this.pushEventTo(this.el, event, payload);
    else this.pushEvent(event, payload);
  },
};

export const DfsUiHooks = { DfsUiDialog };

export default { DfsUiHooks, dfsUiDom, initDfsUi };
