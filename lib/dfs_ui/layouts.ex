defmodule DfsUi.Layouts do
  @moduledoc """
  Layouts nach der zentralen Designvorgabe: `head` (gemeinsame Teile des HTML-Kopfs), `admin`
  (Shell mit heller, einklappbarer Sidebar, Header mit Seitentitel, Profilmenü; nur die
  Hauptfläche scrollt; mobil als Schublade), `auth` (zentrierte Karte unter der Wortmarke) und
  `topbar` (schmale Kopfzeile für Kontoseiten).

  Sidebar- und Menüzustand liegen als `data-sidebar` und `data-nav` am `<html>`-Element, damit
  LiveView-Patches sie nicht zurücksetzen; `dfs_ui.js` schaltet sie um.
  """
  use Phoenix.Component
  import DfsUi.Components

  alias DfsUi.Format

  # Logo und Bildmarke mit Versionskennung (siehe DfsUi.asset_path/2)
  @logo_src DfsUi.asset_path("/images/logo.svg")
  @mark_src DfsUi.asset_path("/images/favicon.svg")

  @init_script """
  (() => {
    const html = document.documentElement;
    const media = matchMedia("(prefers-color-scheme: dark)");
    const applyTheme = () => html.setAttribute("data-theme", media.matches ? "dark" : "light");
    applyTheme();
    media.addEventListener("change", applyTheme);
    try {
      if (localStorage.getItem("dfs:sidebar") === "collapsed") html.setAttribute("data-sidebar", "collapsed");
    } catch (_e) {}
  })();
  """

  @doc """
  Gemeinsame Teile des `<head>`: Farbschema, Favicons aus der Bibliothek und das Skript, das vor
  dem ersten Rendern Dunkelmodus (folgt dem System) und Sidebar-Zustand setzt.
  `base` ist der Pfad, unter dem die App `priv/static` der Bibliothek ausliefert.
  """
  attr :base, :string, default: "/ui"

  def head(assigns) do
    assigns = assign(assigns, :script, @init_script)

    ~H"""
    <meta name="color-scheme" content="light dark" />
    <link rel="icon" href={DfsUi.asset_path("/images/favicon.svg", @base)} type="image/svg+xml" />
    <link rel="alternate icon" href={DfsUi.asset_path("/images/favicon.png", @base)} type="image/png" />
    <link rel="apple-touch-icon" href={"#{@base}/images/apple-touch-icon.png"} />
    <script>
      <%= Phoenix.HTML.raw(@script) %>
    </script>
    """
  end

  @doc """
  Admin-Shell. `nav` ist eine Liste von Maps mit `label`, `icon`, `active` und `href` oder
  `navigate`, optional `group` (Gruppenüberschrift in Kapitälchen).

      <DfsUi.Layouts.admin flash={@flash} page_title="Nutzer" nav={nav(:users)} user={@current_user}>
        <:profile_menu>
          <.menu_item href="/konto" icon="user">Mein Konto</.menu_item>
          <.menu_item href="/abmelden" method="delete" icon="log-out" variant="destructive">Abmelden</.menu_item>
        </:profile_menu>
        …
      </DfsUi.Layouts.admin>
  """
  attr :flash, :map, required: true
  attr :page_title, :string, default: nil
  attr :nav, :list, required: true
  attr :user, :map, default: nil, doc: "angemeldeter Nutzer für Avatar, Name und E-Mail"
  attr :home_href, :string, default: "/admin"
  attr :logo_src, :string, default: @logo_src
  attr :mark_src, :string, default: @mark_src
  attr :logo_alt, :string, default: "Deutschlandfahrschule"
  slot :profile_menu, doc: "Menüpunkte unter Name und E-Mail"
  slot :header, doc: "rechte Seite der Kopfzeile"
  slot :inner_block, required: true

  def admin(assigns) do
    assigns = assign(assigns, :groups, Enum.chunk_by(assigns.nav, &Map.get(&1, :group)))

    ~H"""
    <div class="dfs-shell flex h-dvh overflow-hidden bg-background">
      <div
        class="dfs-nav-backdrop fixed inset-0 z-30 bg-foreground/40"
        data-nav-close
        aria-hidden="true"
      >
      </div>

      <aside
        class="dfs-sidebar fixed inset-y-0 left-0 z-40 flex h-full w-72 shrink-0 flex-col border-r border-sidebar-border bg-sidebar text-sidebar-foreground transition-[width] duration-200 md:static md:w-sidebar"
        aria-label="Seitenleiste"
      >
        <div class="flex h-header shrink-0 items-center justify-between gap-2 border-b border-sidebar-border px-4">
          <.link
            href={@home_href}
            class="dfs-sidebar-expanded flex items-center"
            aria-label="Zur Übersicht"
          >
            <img
              src={@logo_src}
              alt={@logo_alt}
              class="h-8 w-auto max-w-[180px] dark:brightness-0 dark:invert"
            />
          </.link>
          <.link
            href={@home_href}
            class="dfs-sidebar-collapsed mx-auto items-center"
            aria-label="Zur Übersicht"
          >
            <img src={@mark_src} alt="" class="size-8 rounded-md" />
          </.link>
          <button
            type="button"
            class="dfs-sidebar-expanded hidden size-9 shrink-0 items-center justify-center rounded-md text-muted-foreground hover:bg-sidebar-accent hover:text-foreground md:inline-flex"
            data-sidebar-toggle
            aria-label="Menü einklappen"
            title="Menü einklappen"
          >
            <.icon name="panel-left-close" />
          </button>
          <button
            type="button"
            class="inline-flex size-9 shrink-0 items-center justify-center rounded-md hover:bg-sidebar-accent md:hidden"
            data-nav-close
            aria-label="Menü schließen"
          >
            <.icon name="x" />
          </button>
        </div>

        <div class="dfs-sidebar-collapsed justify-center px-2 pt-2">
          <button
            type="button"
            class="inline-flex size-9 items-center justify-center rounded-md text-muted-foreground hover:bg-sidebar-accent hover:text-foreground"
            data-sidebar-toggle
            aria-label="Menü ausklappen"
            title="Menü ausklappen"
          >
            <.icon name="panel-left" />
          </button>
        </div>

        <nav class="flex-1 space-y-1 overflow-y-auto px-2 pt-2 pb-4" aria-label="Hauptnavigation">
          <%= for group <- @groups do %>
            <p
              :if={List.first(group)[:group]}
              class="dfs-sidebar-expanded px-3 pt-3 pb-1 text-xs font-semibold tracking-wide text-muted-foreground uppercase"
            >
              {List.first(group)[:group]}
            </p>
            <.button
              :for={item <- group}
              href={item[:href]}
              navigate={item[:navigate]}
              variant={if item[:active], do: "nav_active", else: "nav"}
              aria-current={if item[:active], do: "page"}
              title={item.label}
              class="dfs-nav-item"
            >
              <.icon name={item[:icon] || "circle"} />
              <span class="dfs-sidebar-expanded flex-1 truncate text-left">{item.label}</span>
            </.button>
          <% end %>
        </nav>

        <div :if={@user} class="mt-auto border-t border-sidebar-border p-2">
          <.dropdown_menu
            id="dfs-profile-menu"
            side="top"
            align="start"
            menu_class="dfs-profile-panel w-56"
          >
            <:trigger>
              <span
                class="menu-item flex w-full items-center gap-3 rounded-md p-2 text-left"
                aria-label="Profilmenü öffnen"
              >
                <.avatar user={@user} />
                <span class="dfs-sidebar-expanded min-w-0 flex-1">
                  <span class="block truncate text-sm font-medium">{Format.display_name(@user)}</span>
                  <span class="block truncate text-xs text-muted-foreground">{Map.get(@user, :email)}</span>
                </span>
                <.icon
                  name="chevrons-up-down"
                  class="dfs-sidebar-expanded h-4 w-4 text-muted-foreground"
                />
              </span>
            </:trigger>
            <.menu_label>
              <span class="block truncate font-medium">{Format.display_name(@user)}</span>
              <span class="block truncate text-xs text-muted-foreground">{Map.get(@user, :email)}</span>
            </.menu_label>
            {render_slot(@profile_menu)}
          </.dropdown_menu>
        </div>
      </aside>

      <div class="flex h-full min-w-0 flex-1 flex-col overflow-hidden">
        <header class="flex h-header shrink-0 items-center justify-between gap-4 border-b bg-card px-4 md:px-6">
          <div class="flex items-center gap-3 md:hidden">
            <button
              type="button"
              class="inline-flex size-9 items-center justify-center rounded-md hover:bg-accent"
              data-nav-toggle
              aria-label="Menü öffnen"
            >
              <.icon name="menu" class="h-5 w-5" />
            </button>
            <img src={@mark_src} alt="" class="size-7 rounded-md" />
          </div>
          <h1 class="min-w-0 flex-1 truncate text-base font-semibold md:text-lg">{@page_title}</h1>
          <div :if={@header != []} class="flex shrink-0 items-center gap-2">
            {render_slot(@header)}
          </div>
        </header>
        <main class="flex-1 overflow-auto overscroll-contain bg-muted/30 p-4 md:p-6">
          <div class="mx-auto flex w-full flex-col gap-4">
            <.flash_group flash={@flash} />
            {render_slot(@inner_block)}
          </div>
        </main>
      </div>
    </div>
    """
  end

  @doc "Login-Layout: Wortmarke, eine Zeile Kontext, zentrierte Karte, Fußzeile."
  attr :flash, :map, required: true
  attr :hint, :string, default: "Dein Konto"
  attr :footer, :string, default: "Deutschlandfahrschule"
  attr :logo_src, :string, default: @logo_src
  slot :inner_block, required: true

  def auth(assigns) do
    ~H"""
    <div class="flex min-h-dvh flex-col items-center justify-center bg-muted/40 px-4 py-12">
      <div class="mb-8 text-center">
        <img
          src={@logo_src}
          alt="Deutschlandfahrschule"
          class="mx-auto mb-3 h-10 w-auto max-w-[280px] dark:brightness-0 dark:invert"
        />
        <p class="text-sm text-muted-foreground">{@hint}</p>
      </div>
      <div class="dfs-fade-in w-full max-w-md space-y-4">
        <.flash_group flash={@flash} />
        {render_slot(@inner_block)}
      </div>
      <p class="mt-8 text-xs text-muted-foreground">{@footer}</p>
    </div>
    """
  end

  @doc "Kopfzeilen-Layout für Kontoseiten: Logo links, Navigation rechts, Inhalt `max-w-5xl`."
  attr :flash, :map, required: true
  attr :home_href, :string, default: "/"
  attr :logo_src, :string, default: @logo_src
  slot :nav, doc: "rechte Seite der Kopfzeile"
  slot :inner_block, required: true

  def topbar(assigns) do
    ~H"""
    <div class="min-h-dvh bg-muted/30">
      <header class="border-b bg-card">
        <div class="mx-auto flex h-header max-w-5xl items-center justify-between gap-4 px-4">
          <.link href={@home_href} class="flex items-center" aria-label="Startseite">
            <img
              src={@logo_src}
              alt="Deutschlandfahrschule"
              class="h-8 w-auto dark:brightness-0 dark:invert"
            />
          </.link>
          <nav class="flex items-center gap-2 text-sm" aria-label="Konto">{render_slot(@nav)}</nav>
        </div>
      </header>
      <main class="mx-auto max-w-5xl px-4 py-6 md:py-8">
        <div class="flex flex-col gap-4">
          <.flash_group flash={@flash} />
          {render_slot(@inner_block)}
        </div>
      </main>
    </div>
    """
  end
end
