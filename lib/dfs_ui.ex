defmodule DfsUi do
  @moduledoc """
  Gemeinsame Oberflächen-Bausteine der Deutschlandfahrschule nach der zentralen Designvorgabe
  (Repo `docs`, `design/README.md`, ADR-0012 und ADR-0014).

  Einbindung in einer Phoenix-App:

      # mix.exs
      {:dfs_ui, github: "deutschlandfahrschule-de/ui", tag: "v0.1.2"}

      # lib/my_app_web.ex, in html_helpers/0 und live_view/0
      import DfsUi.Components
      alias DfsUi.Layouts, as: Ui

      # lib/my_app_web/endpoint.ex: Schriften, Logo und Favicon der Bibliothek
      plug Plug.Static, at: "/ui", from: {:dfs_ui, "priv/static"}, gzip: false, only: ~w(css fonts images)

      # assets/css/app.css
      @import "tailwindcss" source(none);
      @source "../css";
      @source "../../lib/my_app_web";
      @source "../../deps/dfs_ui/lib";
      @import "../../deps/dfs_ui/priv/static/css/tokens.css";
      @import "../../deps/dfs_ui/priv/static/css/tailwind.theme.css";
      @import "../../deps/dfs_ui/priv/static/css/dfs_ui.css";

      # assets/js/app.js
      import {DfsUiHooks, dfsUiDom, initDfsUi} from "dfs_ui"
      initDfsUi()
      const liveSocket = new LiveSocket("/live", Socket, {hooks: {...DfsUiHooks}, dom: dfsUiDom, ...})

  Im `root.html.heex` ersetzt `<DfsUi.Layouts.head />` Favicon-Links und das Skript für
  Dunkelmodus und Sidebar-Zustand. Der Styleguide liegt unter `DfsUi.StyleguideController`.
  """

  @version Mix.Project.config()[:version]

  @doc "Version der Bibliothek (aus mix.exs)."
  def version, do: @version

  @doc """
  Adresse einer Datei aus `priv/static` der Bibliothek mit Versionskennung, z. B.
  `asset_path("/images/logo.svg")` → `"/ui/images/logo.svg?vsn=0.1.4"`, damit Zwischenspeicher
  wie Cloudflare neue Fassungen sofort holen.
  """
  def asset_path(path, base \\ "/ui"), do: base <> path <> "?vsn=" <> @version
end
