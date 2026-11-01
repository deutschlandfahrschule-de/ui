defmodule DfsUi.Styleguide do
  @moduledoc """
  Styleguide: eine Seite, die jeden Baustein in seinen Varianten zeigt. Apps hängen sie in der
  Entwicklung ein (`get "/dev/styleguide", DfsUi.StyleguideController, :index`), damit Änderungen
  an der Bibliothek in beiden Farbmodi geprüft werden können.
  """
  use Phoenix.Component
  import DfsUi.Components

  alias DfsUi.Icons

  @nav [
    %{label: "Übersicht", icon: "layout-dashboard", href: "#", active: true},
    %{label: "Nutzer", icon: "users", href: "#"},
    %{label: "Organisationen", icon: "building-2", href: "#"},
    %{
      label: "Kurse",
      icon: "graduation-cap",
      href: "#",
      group: "Lerninhalte",
      group_icon: "book-open"
    },
    %{label: "Videos", icon: "video", href: "#", group: "Lerninhalte", group_icon: "book-open"},
    %{
      label: "Fragen",
      icon: "list-checks",
      href: "#",
      group: "Lerninhalte",
      group_icon: "book-open"
    },
    %{label: "API-Schlüssel", icon: "key-round", href: "#", group: "System"},
    %{label: "Protokoll", icon: "activity", href: "#", group: "System"}
  ]

  @rows [
    %{
      id: "1",
      name: "Lena Schüler",
      email: "lena.schueler@example.de",
      status: "active",
      n: 1200
    },
    %{
      id: "2",
      name: "Petra Schüler",
      email: "petra.schueler@example.de",
      status: "pending",
      n: 42
    },
    %{id: "3", name: "Sam Support", email: "support@example.de", status: "revoked", n: 0}
  ]

  @doc "Vollständiges HTML-Dokument (für `DfsUi.StyleguideController`)."
  attr :css_path, :string, default: "/assets/css/app.css"
  attr :js_path, :string, default: "/assets/js/app.js"
  attr :app_name, :string, default: "App"
  attr :csrf_token, :string, default: nil

  def document(assigns) do
    ~H"""
    <!DOCTYPE html>
    <html lang="de" class="h-full">
      <head>
        <meta charset="utf-8" />
        <meta name="viewport" content="width=device-width, initial-scale=1" />
        <meta :if={@csrf_token} name="csrf-token" content={@csrf_token} />
        <title>Styleguide · dfs_ui</title>
        <DfsUi.Layouts.head />
        <link rel="stylesheet" href={@css_path} />
        <script type="module" src={@js_path}>
        </script>
      </head>
      <body class="h-full bg-background text-foreground antialiased">
        <.page app_name={@app_name} />
      </body>
    </html>
    """
  end

  @doc "Inhalt des Styleguides innerhalb der Admin-Shell."
  attr :app_name, :string, default: "App"

  def page(assigns) do
    assigns =
      assign(assigns,
        nav: @nav,
        rows: @rows,
        icons: Icons.names(),
        form: sample_form(),
        upload: sample_upload()
      )

    ~H"""
    <DfsUi.Layouts.admin
      flash={%{"info" => "So sieht eine Flash-Meldung aus."}}
      page_title={"Styleguide dfs_ui #{DfsUi.version()}"}
      nav={@nav}
      user={%{name: "Ada Admin", email: "admin@deutschlandfahrschule.de"}}
      home_href="#"
    >
      <:profile_menu>
        <.menu_item href="#" icon="user">Mein Konto</.menu_item>
        <.menu_item href="#" icon="log-out" variant="destructive">Abmelden</.menu_item>
      </:profile_menu>

      <.admin_page width="wide">
        <:toolbar>
          <.input id="sg-search" name="q" value="" placeholder="Suchen…" class="w-64" />
          <.input
            id="sg-status"
            name="status"
            type="select"
            value=""
            prompt="Alle Status"
            options={[{"Aktiv", "active"}, {"Offen", "pending"}]}
            class="w-40"
          />
        </:toolbar>
        <:actions>
          <.button variant="outline"><.icon name="download" /> Export</.button>
          <.button><.icon name="plus" /> Anlegen</.button>
        </:actions>

        <div class="grid gap-4 sm:grid-cols-2 lg:grid-cols-4">
          <.stat_card label="Nutzer gesamt" value={2290} icon="users" />
          <.stat_card label="Aktive Nutzer" value={2104} icon="user-check" tone="success" />
          <.stat_card
            label="Offene Freigaben"
            value={3}
            icon="key-round"
            tone="warning"
            hint="warten auf Bestätigung"
            href="#"
          />
          <.stat_card label="Fehlgeschlagen" value={1} icon="triangle-alert" tone="danger" />
        </div>

        <.section
          title="Buttons"
          icon="square"
          description="Eine Hauptaktion pro Ansicht; alles andere outline, secondary oder ghost."
        >
          <div class="flex flex-wrap items-center gap-2">
            <.button>Hauptaktion</.button>
            <.button variant="secondary">Sekundär</.button>
            <.button variant="outline">Outline</.button>
            <.button variant="ghost">Ghost</.button>
            <.button variant="destructive">Löschen</.button>
            <.button variant="link">Link</.button>
            <.button disabled>Deaktiviert</.button>
          </div>
          <div class="mt-4 flex flex-wrap items-center gap-2">
            <.button size="lg"><.icon name="plus" /> Groß</.button>
            <.button size="sm" variant="outline"><.icon name="pencil" /> Klein</.button>
            <.button size="xs" variant="secondary">Winzig</.button>
            <.button size="icon" variant="outline" aria-label="Suchen"><.icon name="search" /></.button>
            <.button size="icon-sm" variant="ghost" aria-label="Mehr"><.icon name="ellipsis" /></.button>
          </div>
        </.section>

        <div class="grid gap-4 lg:grid-cols-2">
          <.section title="Badges und Status" icon="tag">
            <div class="flex flex-wrap gap-2">
              <.badge :for={tone <- DfsUi.Tones.tones()} tone={tone}>{tone}</.badge>
            </div>
            <div class="mt-3 flex flex-wrap gap-2">
              <.badge :for={tone <- DfsUi.Tones.tones()} tone={tone} variant="solid">{tone}</.badge>
            </div>
            <div class="mt-3 flex flex-wrap gap-2">
              <.badge :for={tone <- DfsUi.Tones.tones()} tone={tone} variant="outline">{tone}</.badge>
            </div>
            <div class="mt-4 flex flex-wrap gap-2">
              <.status_badge
                :for={s <- ~w(active pending disabled archived expired revoked failed locked)}
                status={s}
              />
              <.badge tone="brand" icon="check" size="sm">klein mit Icon</.badge>
            </div>
          </.section>

          <.section title="Hinweise" icon="info">
            <div class="flex flex-col gap-2">
              <.alert variant="info" title="Information">Ein neutraler Hinweis mit Titel.</.alert>
              <.alert variant="success">Gespeichert.</.alert>
              <.alert variant="warning">Der Schlüssel läuft in 3 Tagen ab.</.alert>
              <.alert variant="destructive" title="Fehler" on_close="noop">
                Die Verbindung ist abgebrochen. Bitte erneut versuchen.
              </.alert>
            </div>
          </.section>
        </div>

        <.section
          title="Formular"
          icon="pencil"
          description="Felder 40 px hoch, Fehler in Rot unter dem Feld."
        >
          <form class="grid gap-4 sm:grid-cols-2" onsubmit="return false">
            <.input
              id="sg-email"
              name="email"
              type="email"
              label="E-Mail-Adresse"
              value=""
              placeholder="name@beispiel.de"
            />
            <.input
              id="sg-phone"
              name="phone"
              type="tel"
              label="Mobilnummer"
              value=""
              hint="Mit Vorwahl, z. B. 0151 1234567"
            />
            <.input
              id="sg-pw"
              name="password"
              type="password"
              label="Passwort"
              value=""
              errors={["muss mindestens 8 Zeichen haben"]}
            />
            <.input id="sg-date" name="birthdate" type="date" label="Geburtsdatum" value="" />
            <.input
              id="sg-role"
              name="role"
              type="select"
              label="Rolle"
              value="support"
              options={[{"Plattform-Admin", "platform_admin"}, {"Support", "support"}]}
            />
            <.input
              id="sg-note"
              name="note"
              type="textarea"
              label="Notiz"
              value=""
              placeholder="Optional"
            />
            <.input
              id="sg-check"
              name="confirm"
              type="checkbox"
              label="Sofort aktiv (ohne Bestätigung)"
              checked
            />
            <div class="flex items-end justify-end gap-2">
              <.button variant="outline">Abbrechen</.button>
              <.button type="submit">Speichern</.button>
            </div>
          </form>
        </.section>

        <.section
          title="Dichte Formulare"
          icon="list-checks"
          description="form_field mit FormField: Fehler klein mit Icon, erst nach einem Speicherversuch."
        >
          <.form for={@form} class="grid gap-4 sm:grid-cols-2" onsubmit="return false">
            <.form_errors form={@form} labels={%{title: "Titel"}} class="sm:col-span-2" />
            <.form_field field={@form[:title]} label="Titel" maxlength="200" />
            <.form_field
              field={@form[:kind]}
              type="select"
              label="Art"
              prompt="Bitte wählen"
              options={[{"Video", "video"}, {"Text", "text"}]}
            />
            <.form_field field={@form[:body]} type="textarea" label="Beschreibung" rows={3} />
            <div class="space-y-3">
              <.form_field field={@form[:published]} type="checkbox" label="Veröffentlicht" />
              <.checkbox
                id="sg-cb-ids-1"
                name="ids[]"
                value="1"
                label="Ohne FormField (Mehrfachauswahl)"
                hidden_false={false}
                checked
              />
              <.textarea id="sg-ta" name="note" label="textarea ohne FormField" rows={2} />
            </div>
            <.upload_input
              upload={@upload}
              label="CSV-Dateien"
              hint="Bis zu 5 Dateien, je höchstens 20 MB."
              class="sm:col-span-2"
            />
          </.form>
        </.section>

        <div class="grid gap-4 lg:grid-cols-2">
          <.section title="Chips und Fortschritt" icon="filter">
            <div class="flex flex-wrap gap-2">
              <.chip patch="#" active count={128}>Alle</.chip>
              <.chip patch="#" count={12} tone="danger">Fehlerhaft</.chip>
              <.chip patch="#" count={3} tone="warning">Ungeprüft</.chip>
              <.chip>Ohne Zähler</.chip>
            </div>
            <div class="mt-4 space-y-2">
              <.progress value={72} label="Fortschritt" />
              <.progress value={3} max={4} tone="success" />
              <.progress value={10} tone="warning" show_value={false} />
            </div>
          </.section>
          <.section title="Code" icon="code">
            <.code_block text={~s|{"status": "ok",\n "imported": 1284,\n "skipped": 3}|} />
          </.section>
        </div>

        <.section title="Tabelle" icon="list" count={length(@rows)} padded={false}>
          <:actions>
            <.button size="sm" variant="outline"><.icon name="download" /> CSV</.button>
          </:actions>
          <.table rows={@rows} empty="Keine Einträge.">
            <:col :let={r} label="Name"><span class="font-medium">{r.name}</span></:col>
            <:col :let={r} label="E-Mail" class="text-muted-foreground">{r.email}</:col>
            <:col :let={r} label="Status"><.status_badge status={r.status} /></:col>
            <:col :let={r} label="Punkte" align="right">{DfsUi.Format.number(r.n)}</:col>
            <:action :let={_r}><.button size="sm" variant="ghost">Bearbeiten</.button></:action>
          </.table>
          <.pager
            page={2}
            total={57}
            per_page={25}
            path={fn p -> "#page-#{p}" end}
            class="border-t px-4 py-3"
          />
        </.section>

        <div class="grid gap-4 lg:grid-cols-2">
          <.section title="Leerer Zustand" icon="inbox" padded={false}>
            <.empty_state icon="users">
              Noch keine Nutzer vorhanden.
              <:action><.button size="sm" variant="outline">Filter zurücksetzen</.button></:action>
            </.empty_state>
          </.section>
          <.section title="Stammdaten" icon="id-card">
            <.kv_list>
              <:item label="E-Mail">lena.schueler@example.de</:item>
              <:item label="Status"><.status_badge status="active" /></:item>
              <:item label="Angelegt">{DfsUi.Format.datetime(~U[2026-10-29 10:15:00Z])}</:item>
            </.kv_list>
          </.section>
        </div>

        <.section title="Tabs, Dialog, Menü" icon="layers">
          <.tabs>
            <:tab label="Profil" href="#" active />
            <:tab label="Rollen" href="#" count={2} />
            <:tab label="Protokoll" href="#" />
          </.tabs>
          <div class="mt-4 flex flex-wrap gap-2">
            <.button variant="outline" data-dialog-open="sg-dialog">Dialog öffnen</.button>
            <.dropdown_menu id="sg-menu">
              <:trigger>
                <span class="inline-flex h-10 items-center gap-2 rounded-md border border-input bg-background px-4 text-sm font-medium hover:bg-accent">
                  Menü <.icon name="chevron-down" />
                </span>
              </:trigger>
              <.menu_item href="#" icon="pencil">Bearbeiten</.menu_item>
              <.menu_item href="#" icon="copy">Duplizieren</.menu_item>
              <.menu_item href="#" icon="trash-2" variant="destructive">Löschen</.menu_item>
            </.dropdown_menu>
            <.avatar user={%{name: "Lena Schüler"}} size="sm" />
            <.avatar user={%{name: "Lena Schüler"}} />
            <.avatar user={%{email: "x@example.de"}} size="lg" />
          </div>
          <.dialog
            id="sg-dialog"
            title="Neues Passwort setzen"
            description="Alle Sitzungen werden dabei beendet."
          >
            <.input id="sg-dialog-pw" name="password" type="password" label="Passwort" value="" />
            <:footer>
              <.button variant="outline" data-dialog-close>Abbrechen</.button>
              <.button data-dialog-close>Speichern</.button>
            </:footer>
          </.dialog>
        </.section>

        <.section title="Icons" icon="star" count={length(@icons)}>
          <div class="grid grid-cols-4 gap-3 text-xs text-muted-foreground sm:grid-cols-6 lg:grid-cols-10">
            <div
              :for={name <- @icons}
              class="flex flex-col items-center gap-1 rounded-md p-2 hover:bg-accent"
            >
              <.icon name={name} class="h-5 w-5 text-foreground" />
              <span class="truncate">{name}</span>
            </div>
          </div>
        </.section>
      </.admin_page>
    </DfsUi.Layouts.admin>
    """
  end

  defp sample_form do
    Phoenix.Component.to_form(
      %{"title" => "", "kind" => "video", "body" => "", "published" => "true"},
      as: :sample,
      id: "sg-form",
      errors: [title: {"darf nicht leer sein", []}, title: {"ist zu kurz", []}]
    )
  end

  defp sample_upload do
    conf =
      Phoenix.LiveView.UploadConfig.build(:csv, "sg-upload",
        accept: ~w(.csv),
        max_entries: 5,
        max_file_size: 20_000_000
      )

    entry = %Phoenix.LiveView.UploadEntry{
      ref: "0",
      upload_ref: "sg-upload",
      upload_config: :csv,
      client_name: "fragen_2026.csv",
      progress: 40
    }

    %{conf | entries: [entry], errors: [{"0", :too_large}]}
  end
end
