// Gemeinsames JavaScript der Deutschlandfahrschule-Oberflächen (dfs_ui).
// Funktioniert in LiveViews (Hooks) und in normalen Seiten (Delegation am Dokument).

const html = () => document.documentElement;

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
      if (dialog && !dialog.open && !dialog.dataset.live) dialog.showModal();
      return;
    }
    const closer = target.closest("[data-dialog-close]");
    if (closer) {
      const dialog = closer.closest("dialog");
      if (dialog && dialog.open && !dialog.dataset.live) dialog.close();
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
    if (dialog instanceof HTMLDialogElement && dialog.open && !dialog.dataset.live) {
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

/** Dialog-Hook: der Server besitzt den Zustand (data-open), der Browser ruft showModal()/close(). */
const DfsUiDialog = {
  mounted() {
    this.el.dataset.live = "true";
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
    if (this.el.open) this.el.close();
  },
  sync() {
    const wanted = this.el.dataset.open === "true";
    if (wanted && !this.el.open) this.el.showModal();
    if (!wanted && this.el.open) this.el.close();
  },
  requestClose() {
    const event = this.el.dataset.onClose || "close_dialog";
    const payload = { id: this.el.id };
    if (this.el.getAttribute("phx-target")) this.pushEventTo(this.el, event, payload);
    else this.pushEvent(event, payload);
  },
};

export const DfsUiHooks = { DfsUiDialog };

export default { DfsUiHooks, initDfsUi };
