# dfs_ui

Gemeinsame Oberflächen-Bausteine der Deutschlandfahrschule für Phoenix-Apps: Tokens, CSS,
Icons, HEEx-Komponenten, Layouts und ein Styleguide. Umsetzung der
[Designvorgabe](https://github.com/deutschlandfahrschule-de/docs/tree/main/design)
(ADR-0012) nach [ADR-0014](https://github.com/deutschlandfahrschule-de/docs/blob/main/entscheidungen/ADR-0014-liveview-und-ui-bibliothek.md).

## Einbinden

```elixir
# mix.exs
{:dfs_ui, github: "deutschlandfahrschule-de/ui", tag: "v0.2.1"}
```

```elixir
# lib/my_app_web.ex – in html_helpers/0 (und damit in live_view/0, html/0)
import DfsUi.Components
alias DfsUi.Layouts, as: Ui
```

```elixir
# lib/my_app_web/endpoint.ex – Schriften, Logo, Favicon aus der Bibliothek
plug Plug.Static, at: "/ui", from: {:dfs_ui, "priv/static"}, gzip: false, only: ~w(css fonts images)
```

```css
/* assets/css/app.css */
@import "tailwindcss" source(none);
@source "../css";
@source "../../lib/my_app_web";
@source "../../deps/dfs_ui/lib";
@import "../../deps/dfs_ui/priv/static/css/tokens.css";
@import "../../deps/dfs_ui/priv/static/css/tailwind.theme.css";
@import "../../deps/dfs_ui/priv/static/css/dfs_ui.css";
```

```js
// assets/js/app.js
import "phoenix_html"
import {Socket} from "phoenix"
import {LiveSocket} from "phoenix_live_view"
import {DfsUiHooks, dfsUiDom, initDfsUi} from "dfs_ui"

initDfsUi()
const csrfToken = document.querySelector("meta[name='csrf-token']").getAttribute("content")
const liveSocket = new LiveSocket("/live", Socket, {params: {_csrf_token: csrfToken}, hooks: {...DfsUiHooks}, dom: dfsUiDom})
liveSocket.connect()
```

```heex
<%!-- root.html.heex --%>
<head>
  <meta charset="utf-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1" />
  <meta name="csrf-token" content={get_csrf_token()} />
  <title>…</title>
  <DfsUi.Layouts.head />
  <link phx-track-static rel="stylesheet" href={~p"/assets/css/app.css"} />
  <script type="module" phx-track-static src={~p"/assets/js/app.js"}></script>
</head>
```

Styleguide in der Entwicklung:

```elixir
scope "/dev" do
  pipe_through :browser
  get "/styleguide", DfsUi.StyleguideController, :index
end
```

## Bausteine

| Komponente | Zweck |
|---|---|
| `icon` | Lucide-Icon als Inline-SVG (`DfsUi.Icons.names/0` listet alle) |
| `button` | Button oder Link im Button-Stil; Varianten default, secondary, outline, ghost, destructive, link, nav |
| `badge`, `status_badge` | Tone-Badges; Status → Tone und Beschriftung zentral in `DfsUi.Tones` |
| `alert`, `flash_group` | Hinweise und Flash-Meldungen |
| `input`, `label`, `error` | Felder mit Label, Hinweis und Fehlern; `field={@form[:x]}` oder `name`/`value` (beides optional) |
| `form_field`, `field_errors`, `form_errors` | Dichte Formulare aus `FormField` (kleine Fehler mit Icon), Fehlersammlung als Hinweisbox (auch verschachtelte Changeset-Fehler) |
| `textarea`, `checkbox` | Felder ohne FormField; `checkbox` mit eigenem `value` für Mehrfachauswahl (`hidden_false={false}`) |
| `upload_input` | Dateiauswahl für LiveView-Uploads mit Dateiliste, Fortschritt, Entfernen und deutschen Fehlern (`upload_error/2`) |
| `chip`, `progress`, `code_block` | Filter-Chip mit Zähler, Fortschrittsbalken, Code-/Rohtext-Box |
| `admin_page`, `page_header`, `section`, `stat_card` | Seitengerüst, Detailkopf, betitelte Karte, Kennzahl |
| `table`, `pager`, `empty_state`, `kv_list` | Listen und Stammdaten |
| `tabs` | Tab-Leiste aus Links (`href` oder `patch`) |
| `dialog` | Modaler Dialog (`<dialog>`), Zustand in LiveViews vom Server (`open`, Event `close_dialog`) |
| `dropdown_menu`, `menu_label`, `menu_item` | Aufklappmenü auf `<details>`-Basis |
| `avatar`, `separator`, `code` | Kleinteile |

Layouts: `DfsUi.Layouts.admin` (Shell mit Sidebar und Profilmenü; Navigationsgruppen mit
`group_icon` sind aufklappbar), `auth` (Login), `topbar` (Kontoseiten), `head` (gemeinsamer
HTML-Kopf). Formatierer: `DfsUi.Format`.

Fehlertexte: `translate_error/1` setzt nur Platzhalter ein, die im Text stehen (Ecto-Optionen
wie `type: {:array, :string}` stören nicht); eigene Übersetzung über
`config :dfs_ui, translate_error: {MyAppWeb.Gettext, :translate_error}`.

## Dialog in einer LiveView

```heex
<.button phx-click="open_dialog" phx-value-id="password">Passwort setzen</.button>

<.dialog id="password" title="Neues Passwort setzen" open={@dialog == "password"}>
  <.form for={@pw_form} id="password-form" phx-submit="set_password">
    <.input field={@pw_form[:password]} type="password" label="Passwort" />
  </.form>
  <:footer>
    <.button variant="outline" phx-click="close_dialog" phx-value-id="password">Abbrechen</.button>
    <.button type="submit" form="password-form">Speichern</.button>
  </:footer>
</.dialog>
```

```elixir
def handle_event("open_dialog", %{"id" => id}, socket), do: {:noreply, assign(socket, :dialog, id)}
def handle_event("close_dialog", _, socket), do: {:noreply, assign(socket, :dialog, nil)}
```

In Seiten ohne LiveView öffnet `data-dialog-open="password"` den Dialog, `data-dialog-close`
schließt ihn.

## Ändern und veröffentlichen

1. Änderung in `lib/`, `priv/static/css/` oder `assets/js/`, Styleguide in einer App prüfen
   (hell und dunkel), `mix test`.
2. `CHANGELOG.md` ergänzen, Version in `mix.exs` und `package.json` anheben.
3. `git tag v0.x.y && git push --tags`, in den Apps die Version in `mix.exs` anheben und
   `mix deps.update dfs_ui`.

Icons stammen aus Lucide (ISC); neue Icons werden in `lib/dfs_ui/icons.ex` ergänzt.
