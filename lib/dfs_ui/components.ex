defmodule DfsUi.Components do
  @moduledoc """
  Bausteine der Oberfläche nach der zentralen Designvorgabe (docs/design, ADR-0012, ADR-0014) als
  HEEx-Funktionskomponenten. Sie funktionieren in LiveViews und in normalen Templates; was JS
  braucht (Dialog, Sidebar, Menüs), liefert `assets/js/dfs_ui.js`.

  Import in `my_app_web.ex`: `import DfsUi.Components`.
  """
  use Phoenix.Component

  alias Phoenix.LiveView.JS
  alias DfsUi.{Format, Icons, Tones}

  ## Icon

  @doc "Inline-SVG-Icon (Lucide). Unbekannte Namen zeichnen einen Kreis."
  attr :name, :string, required: true
  attr :class, :any, default: "h-4 w-4"
  attr :rest, :global

  def icon(assigns) do
    ~H"""
    <svg
      xmlns="http://www.w3.org/2000/svg"
      viewBox="0 0 24 24"
      fill="none"
      stroke="currentColor"
      stroke-width="2"
      stroke-linecap="round"
      stroke-linejoin="round"
      class={["shrink-0", @class]}
      aria-hidden="true"
      {@rest}
    >
      {Phoenix.HTML.raw(Icons.path(@name))}
    </svg>
    """
  end

  ## Button

  @button_base "inline-flex shrink-0 items-center justify-center gap-2 rounded-md text-sm font-medium whitespace-nowrap ring-offset-background transition-colors outline-none focus-visible:ring-2 focus-visible:ring-ring focus-visible:ring-offset-2 disabled:pointer-events-none disabled:opacity-50 cursor-pointer [&_svg]:pointer-events-none [&_svg]:shrink-0"

  @button_variants %{
    "default" => "bg-primary text-primary-foreground hover:bg-primary/90",
    "destructive" =>
      "bg-destructive text-destructive-foreground hover:bg-destructive/90 focus-visible:ring-destructive",
    "outline" => "border border-input bg-background hover:bg-accent hover:text-accent-foreground",
    "secondary" => "bg-secondary text-secondary-foreground hover:bg-secondary/80",
    "ghost" => "hover:bg-accent hover:text-accent-foreground",
    "link" => "text-brand underline-offset-4 hover:underline",
    "nav" => "menu-item w-full justify-start font-normal",
    "nav_active" => "menu-item menu-item-active w-full justify-start"
  }

  @button_sizes %{
    "default" => "h-10 px-4 py-2 has-[>svg]:px-3",
    "sm" => "h-9 gap-1.5 px-3 has-[>svg]:px-2.5",
    "xs" => "h-7 gap-1 px-2 text-xs [&_svg]:size-3",
    "lg" => "h-11 px-6 has-[>svg]:px-4",
    "icon" => "size-10",
    "icon-sm" => "size-9",
    "icon-xs" => "size-7 [&_svg]:size-3"
  }

  @doc """
  Button oder Link im Button-Stil. Mit `href`, `navigate` oder `patch` wird ein `<a>` gerendert
  (`method="delete"` erzeugt einen Formular-Link über phoenix_html).
  Varianten: default (die eine Hauptaktion), secondary, outline, ghost, destructive, link, nav.
  """
  attr :variant, :string, default: "default", values: Map.keys(@button_variants)
  attr :size, :string, default: "default", values: Map.keys(@button_sizes)
  attr :href, :string, default: nil
  attr :navigate, :string, default: nil
  attr :patch, :string, default: nil
  attr :method, :string, default: nil
  attr :type, :string, default: "button"
  attr :class, :any, default: nil

  attr :rest, :global,
    include: ~w(disabled form name value aria-label aria-current title target rel download)

  slot :inner_block, required: true

  def button(%{href: href, navigate: navigate, patch: patch} = assigns)
      when is_binary(href) or is_binary(navigate) or is_binary(patch) do
    assigns = assign(assigns, :classes, button_classes(assigns))

    ~H"""
    <.link
      href={@href}
      navigate={@navigate}
      patch={@patch}
      method={@method}
      class={@classes}
      {@rest}
    >
      {render_slot(@inner_block)}
    </.link>
    """
  end

  def button(assigns) do
    assigns = assign(assigns, :classes, button_classes(assigns))

    ~H"""
    <button type={@type} class={@classes} {@rest}>{render_slot(@inner_block)}</button>
    """
  end

  defp button_classes(%{variant: variant, size: size, class: class}) do
    [@button_base, Map.fetch!(@button_variants, variant), Map.fetch!(@button_sizes, size), class]
  end

  ## Badges

  @tone_classes %{
    "neutral" => %{
      "soft" => "bg-tone-neutral-bg text-tone-neutral-fg",
      "solid" => "bg-tone-neutral-solid text-white",
      "outline" => "border border-tone-neutral-border text-tone-neutral-fg"
    },
    "info" => %{
      "soft" => "bg-tone-info-bg text-tone-info-fg",
      "solid" => "bg-tone-info-solid text-white",
      "outline" => "border border-tone-info-border text-tone-info-fg"
    },
    "success" => %{
      "soft" => "bg-tone-success-bg text-tone-success-fg",
      "solid" => "bg-tone-success-solid text-white",
      "outline" => "border border-tone-success-border text-tone-success-fg"
    },
    "warning" => %{
      "soft" => "bg-tone-warning-bg text-tone-warning-fg",
      "solid" => "bg-tone-warning-solid text-white",
      "outline" => "border border-tone-warning-border text-tone-warning-fg"
    },
    "danger" => %{
      "soft" => "bg-tone-danger-bg text-tone-danger-fg",
      "solid" => "bg-tone-danger-solid text-white",
      "outline" => "border border-tone-danger-border text-tone-danger-fg"
    },
    "brand" => %{
      "soft" => "bg-tone-brand-bg text-tone-brand-fg",
      "solid" => "bg-tone-brand-solid text-white",
      "outline" => "border border-tone-brand-border text-tone-brand-fg"
    },
    "accent" => %{
      "soft" => "bg-tone-accent-bg text-tone-accent-fg",
      "solid" => "bg-tone-accent-solid text-white",
      "outline" => "border border-tone-accent-border text-tone-accent-fg"
    }
  }

  @doc "Badge mit Tone-Farben für Zustände oder Kategorien."
  attr :tone, :string, default: "neutral", values: Map.keys(@tone_classes)
  attr :variant, :string, default: "soft", values: ~w(soft solid outline)
  attr :size, :string, default: "md", values: ~w(sm md)
  attr :icon, :string, default: nil
  attr :class, :any, default: nil
  attr :rest, :global
  slot :inner_block, required: true

  def badge(assigns) do
    ~H"""
    <span
      class={[
        "inline-flex items-center gap-1 whitespace-nowrap rounded-full font-semibold",
        @size == "md" && "px-2.5 py-0.5 text-xs",
        @size == "sm" && "px-1.5 py-0 text-[10px]",
        tone_class(@tone, @variant),
        @class
      ]}
      {@rest}
    >
      <.icon :if={@icon} name={@icon} class="h-3 w-3" />
      {render_slot(@inner_block)}
    </span>
    """
  end

  @doc "Statusbadge für Datensatz-Zustände (active, pending, revoked …) mit zentraler Zuordnung."
  attr :status, :any, required: true
  attr :tone, :string, default: nil, doc: "überschreibt die zentrale Zuordnung"
  attr :label, :string, default: nil, doc: "überschreibt die zentrale Beschriftung"
  attr :class, :any, default: nil

  def status_badge(assigns) do
    assigns =
      assigns
      |> assign_new(:resolved_tone, fn -> assigns.tone || Tones.tone_for(assigns.status) end)
      |> assign_new(:resolved_label, fn -> assigns.label || Tones.label_for(assigns.status) end)

    ~H"""
    <.badge tone={@resolved_tone} class={@class}>{@resolved_label}</.badge>
    """
  end

  ## Hinweise und Flash

  @alert_classes %{
    "info" => "border-tone-info-border bg-tone-info-bg text-tone-info-fg",
    "success" => "border-tone-success-border bg-tone-success-bg text-tone-success-fg",
    "warning" => "border-tone-warning-border bg-tone-warning-bg text-tone-warning-fg",
    "destructive" => "border-tone-danger-border bg-tone-danger-bg text-tone-danger-fg"
  }

  @alert_icons %{
    "info" => "info",
    "success" => "circle-check",
    "warning" => "triangle-alert",
    "destructive" => "circle-x"
  }

  @doc "Inline-Hinweis mit Tone-Farben und Icon links; mit `on_close` schließbar."
  attr :variant, :string, default: "info", values: Map.keys(@alert_classes)
  attr :title, :string, default: nil
  attr :class, :any, default: nil
  attr :on_close, :any, default: nil, doc: "JS-Befehl oder Event-Name für den Schließen-Knopf"
  attr :rest, :global
  slot :inner_block, required: true

  def alert(assigns) do
    ~H"""
    <div
      role={if @variant == "destructive", do: "alert", else: "status"}
      class={[
        "flex items-start gap-3 rounded-lg border px-4 py-3 text-sm",
        alert_class(@variant),
        @class
      ]}
      {@rest}
    >
      <.icon name={alert_icon(@variant)} class="mt-0.5 h-4 w-4" />
      <div class="min-w-0 flex-1">
        <p :if={@title} class="font-medium">{@title}</p>
        <div>{render_slot(@inner_block)}</div>
      </div>
      <button
        :if={@on_close}
        type="button"
        class="-m-1 rounded-md p-1 opacity-70 hover:opacity-100"
        aria-label="Schließen"
        phx-click={@on_close}
        data-dismiss
      >
        <.icon name="x" class="h-4 w-4" />
      </button>
    </div>
    """
  end

  @doc """
  Flash-Meldungen (info, error) als Hinweise. Funktioniert mit String- und Atom-Schlüsseln;
  in LiveViews schließt der Knopf über `lv:clear-flash`.
  """
  attr :flash, :map, required: true
  attr :class, :any, default: nil

  def flash_group(assigns) do
    assigns =
      assign(assigns,
        info: flash_value(assigns.flash, :info),
        error: flash_value(assigns.flash, :error)
      )

    ~H"""
    <div :if={@info || @error} class={["flex flex-col gap-2", @class]} aria-live="polite">
      <.alert
        :if={@info}
        variant="success"
        on_close={JS.push("lv:clear-flash", value: %{key: "info"}) |> JS.hide(to: "#dfs-flash-info")}
        id="dfs-flash-info"
      >
        {@info}
      </.alert>
      <.alert
        :if={@error}
        variant="destructive"
        on_close={
          JS.push("lv:clear-flash", value: %{key: "error"}) |> JS.hide(to: "#dfs-flash-error")
        }
        id="dfs-flash-error"
      >
        {@error}
      </.alert>
    </div>
    """
  end

  defp flash_value(flash, key) when is_map(flash) do
    Map.get(flash, key) || Map.get(flash, to_string(key))
  end

  defp flash_value(_, _), do: nil

  ## Formulare

  @input_class "flex h-10 w-full min-w-0 rounded-md border border-input bg-background px-3 py-2 text-base text-input-foreground ring-offset-background outline-none placeholder:text-muted-foreground/70 focus-visible:ring-2 focus-visible:ring-ring focus-visible:ring-offset-2 disabled:cursor-not-allowed disabled:opacity-50 aria-invalid:border-destructive md:text-sm"

  @doc "Beschriftung eines Feldes."
  attr :for, :string, default: nil
  attr :class, :any, default: nil
  slot :inner_block, required: true

  def label(assigns) do
    ~H"""
    <label for={@for} class={["text-sm font-medium leading-none", @class]}>
      {render_slot(@inner_block)}
    </label>
    """
  end

  @doc "Fehlermeldung unter einem Feld."
  attr :class, :any, default: nil
  slot :inner_block, required: true

  def error(assigns) do
    ~H"""
    <p class={["text-sm text-destructive", @class]}>{render_slot(@inner_block)}</p>
    """
  end

  @doc """
  Eingabefeld mit Label, Hinweis und Fehlern. Mit `field={@form[:email]}` kommen id, name, Wert
  und Fehler aus dem Formular; sonst `name` und `value` setzen.

  `type`: text, email, password, tel, date, number, url, search, textarea, select, checkbox,
  hidden. Für select `options` als `{label, value}`-Liste und optional `prompt`.
  """
  attr :id, :any, default: nil
  attr :name, :any
  attr :label, :string, default: nil
  attr :value, :any
  attr :type, :string, default: "text"
  attr :field, Phoenix.HTML.FormField, doc: "Formularfeld, z. B. @form[:email]"
  attr :errors, :list, default: []
  attr :hint, :string, default: nil
  attr :checked, :boolean, doc: "für checkbox"
  attr :prompt, :string, default: nil, doc: "für select"
  attr :options, :list, doc: "für select: Liste von {label, value}"
  attr :multiple, :boolean, default: false
  attr :class, :any, default: nil, doc: "Klassen des umschließenden Blocks"
  attr :input_class, :any, default: nil

  attr :rest, :global,
    include:
      ~w(accept autocomplete autofocus disabled form inputmode list max maxlength min minlength pattern placeholder readonly required rows size step)

  def input(%{field: %Phoenix.HTML.FormField{} = field} = assigns) do
    errors = if Phoenix.Component.used_input?(field), do: field.errors, else: []

    assigns
    |> assign(field: nil, id: assigns.id || field.id)
    |> assign(:errors, Enum.map(errors, &translate_error/1))
    |> assign_new(:name, fn -> if assigns.multiple, do: field.name <> "[]", else: field.name end)
    |> assign_new(:value, fn -> field.value end)
    |> input()
  end

  def input(%{type: "hidden"} = assigns) do
    ~H"""
    <input type="hidden" id={@id} name={@name} value={@value} {@rest} />
    """
  end

  def input(%{type: "checkbox"} = assigns) do
    assigns =
      assign_new(assigns, :checked, fn ->
        Phoenix.HTML.Form.normalize_value("checkbox", assigns[:value])
      end)

    ~H"""
    <div class={["space-y-1", @class]}>
      <label class="flex cursor-pointer items-center gap-2 text-sm">
        <input type="hidden" name={@name} value="false" disabled={@rest[:disabled]} />
        <input
          type="checkbox"
          id={@id}
          name={@name}
          value="true"
          checked={@checked}
          class="size-4 shrink-0 rounded border border-input accent-primary focus-visible:ring-2 focus-visible:ring-ring focus-visible:ring-offset-2"
          {@rest}
        />
        <span>{@label}</span>
      </label>
      <p :if={@hint} class="text-xs text-muted-foreground">{@hint}</p>
      <.error :for={msg <- @errors}>{msg}</.error>
    </div>
    """
  end

  def input(%{type: "select"} = assigns) do
    ~H"""
    <div class={["space-y-2", @class]}>
      <.label :if={@label} for={@id}>{@label}</.label>
      <select
        id={@id}
        name={@name}
        multiple={@multiple}
        aria-invalid={@errors != [] && "true"}
        class={[
          select_class(),
          @errors != [] && "border-destructive",
          @input_class
        ]}
        {@rest}
      >
        <option :if={@prompt} value="">{@prompt}</option>
        {Phoenix.HTML.Form.options_for_select(@options, @value)}
      </select>
      <p :if={@hint} class="text-xs text-muted-foreground">{@hint}</p>
      <.error :for={msg <- @errors}>{msg}</.error>
    </div>
    """
  end

  def input(%{type: "textarea"} = assigns) do
    ~H"""
    <div class={["space-y-2", @class]}>
      <.label :if={@label} for={@id}>{@label}</.label>
      <textarea
        id={@id}
        name={@name}
        aria-invalid={@errors != [] && "true"}
        class={[
          input_class(),
          "h-auto min-h-24",
          @errors != [] && "border-destructive",
          @input_class
        ]}
        {@rest}
      >{Phoenix.HTML.Form.normalize_value("textarea", @value)}</textarea>
      <p :if={@hint} class="text-xs text-muted-foreground">{@hint}</p>
      <.error :for={msg <- @errors}>{msg}</.error>
    </div>
    """
  end

  def input(assigns) do
    ~H"""
    <div class={["space-y-2", @class]}>
      <.label :if={@label} for={@id}>{@label}</.label>
      <input
        type={@type}
        id={@id}
        name={@name}
        value={Phoenix.HTML.Form.normalize_value(@type, @value)}
        aria-invalid={@errors != [] && "true"}
        class={[input_class(), @errors != [] && "border-destructive", @input_class]}
        {@rest}
      />
      <p :if={@hint} class="text-xs text-muted-foreground">{@hint}</p>
      <.error :for={msg <- @errors}>{msg}</.error>
    </div>
    """
  end

  defp input_class, do: @input_class

  defp select_class,
    do:
      "flex h-10 w-full min-w-0 rounded-md border border-input bg-background px-3 py-2 text-base text-input-foreground ring-offset-background outline-none focus-visible:ring-2 focus-visible:ring-ring focus-visible:ring-offset-2 disabled:cursor-not-allowed disabled:opacity-50 md:text-sm"

  @doc """
  Übersetzt Ecto-Fehler (`{msg, opts}`) mit Interpolation. Apps mit Gettext konfigurieren
  `config :dfs_ui, translate_error: {MyAppWeb.Gettext, :translate_error}`; die Funktion
  bekommt `{msg, opts}`.
  """
  def translate_error({msg, opts}) do
    case Application.get_env(:dfs_ui, :translate_error) do
      {mod, fun} ->
        apply(mod, fun, [{msg, opts}])

      _ ->
        Enum.reduce(opts, msg, fn {key, value}, acc ->
          String.replace(acc, "%{#{key}}", to_string(value))
        end)
    end
  end

  def translate_error(msg) when is_binary(msg), do: msg

  ## Seitengerüst

  @doc """
  Seitengerüst: Werkzeugleiste (Filter links, Aktionen rechts) und Inhalt mit `gap-4`.
  `width`: full (Tabellen), wide (Dashboards, 1280 px), narrow (Formulare, 48 rem).
  """
  attr :width, :string, default: "full", values: ~w(full wide narrow)
  attr :class, :any, default: nil
  slot :toolbar
  slot :actions
  slot :inner_block, required: true

  def admin_page(assigns) do
    ~H"""
    <div class={[
      "flex w-full flex-col gap-4",
      @width == "wide" && "mx-auto max-w-[1280px]",
      @width == "narrow" && "mx-auto max-w-3xl",
      @class
    ]}>
      <div :if={@toolbar != [] or @actions != []} class="flex min-h-10 flex-wrap items-center gap-3">
        <div class="flex min-w-0 flex-1 flex-wrap items-center gap-2">
          {render_slot(@toolbar)}
        </div>
        <div :if={@actions != []} class="flex shrink-0 items-center gap-2">
          {render_slot(@actions)}
        </div>
      </div>
      <div class="flex flex-col gap-4">
        {render_slot(@inner_block)}
      </div>
    </div>
    """
  end

  @doc "Kopf einer Detailseite: Titel, Badges daneben, Untertitel, Aktionen rechts."
  attr :title, :string, required: true
  attr :subtitle, :string, default: nil
  attr :class, :any, default: nil
  slot :badges
  slot :meta, doc: "weitere Zeilen unter dem Untertitel"
  slot :actions

  def page_header(assigns) do
    ~H"""
    <div class={["flex flex-wrap items-start justify-between gap-4", @class]}>
      <div class="min-w-0">
        <div class="flex flex-wrap items-center gap-3">
          <h2 class="text-2xl font-semibold tracking-tight">{@title}</h2>
          {render_slot(@badges)}
        </div>
        <p :if={@subtitle} class="text-sm text-muted-foreground">{@subtitle}</p>
        {render_slot(@meta)}
      </div>
      <div :if={@actions != []} class="flex flex-wrap gap-2">{render_slot(@actions)}</div>
    </div>
    """
  end

  @doc "Betitelte Karte für einen Abschnitt. `padded={false}` für Tabellen bis zum Kartenrand."
  attr :title, :string, default: nil
  attr :description, :string, default: nil
  attr :icon, :string, default: nil
  attr :count, :integer, default: nil
  attr :padded, :boolean, default: true
  attr :class, :any, default: nil
  attr :rest, :global
  slot :actions
  slot :inner_block, required: true

  def section(assigns) do
    ~H"""
    <section
      class={["flex flex-col rounded-lg border bg-card text-card-foreground shadow-xs", @class]}
      {@rest}
    >
      <header
        :if={@title || @actions != []}
        class="flex flex-row items-start justify-between gap-4 px-6 pt-6 pb-4"
      >
        <div class="space-y-1">
          <h2 class="flex items-center gap-2 text-lg leading-none font-semibold">
            <.icon :if={@icon} name={@icon} class="h-5 w-5 text-brand" />
            {@title}
            <span :if={is_integer(@count)} class="text-sm font-normal text-muted-foreground">
              ({Format.number(@count)})
            </span>
          </h2>
          <p :if={@description} class="text-sm text-muted-foreground">{@description}</p>
        </div>
        <div :if={@actions != []} class="flex shrink-0 items-center gap-2">
          {render_slot(@actions)}
        </div>
      </header>
      <div class={[@padded && "px-6 pb-6", @padded && is_nil(@title) && @actions == [] && "pt-6"]}>
        {render_slot(@inner_block)}
      </div>
    </section>
    """
  end

  @value_tones %{
    "neutral" => "text-tone-neutral-solid",
    "info" => "text-tone-info-solid",
    "success" => "text-tone-success-solid",
    "warning" => "text-tone-warning-solid",
    "danger" => "text-tone-danger-solid",
    "brand" => "text-tone-brand-solid",
    "accent" => "text-tone-accent-solid"
  }

  @doc "Kennzahl-Kachel: Label, großer Wert, optional Icon, Tone, Hinweis und Link."
  attr :label, :string, required: true
  attr :value, :any, required: true
  attr :icon, :string, default: nil
  attr :tone, :string, default: nil
  attr :hint, :string, default: nil
  attr :href, :string, default: nil
  attr :class, :any, default: nil

  def stat_card(assigns) do
    ~H"""
    <div class={["rounded-lg border bg-card p-6 text-card-foreground shadow-xs", @class]}>
      <div class="flex items-center justify-between gap-2">
        <span class="text-sm font-medium text-muted-foreground">{@label}</span>
        <.icon :if={@icon} name={@icon} class="h-4 w-4 text-muted-foreground" />
      </div>
      <div class={["mt-2 text-2xl font-bold tabular-nums", @tone && value_tone(@tone)]}>
        {if is_integer(@value), do: Format.number(@value), else: @value}
      </div>
      <p :if={@hint} class="mt-1 text-xs text-muted-foreground">
        <%= if @href do %>
          <.link href={@href} class="text-brand underline-offset-4 hover:underline">{@hint}</.link>
        <% else %>
          {@hint}
        <% end %>
      </p>
    </div>
    """
  end

  ## Tabelle, Pager, Listen

  @doc """
  Tabelle mit Spalten-Slots. Leerer Zustand als eine Zeile über alle Spalten.

      <.table rows={@keys} empty="Keine Schlüssel vorhanden.">
        <:col :let={key} label="Name">{key.name}</:col>
        <:action :let={key}><.button size="sm" variant="ghost">Löschen</.button></:action>
      </.table>

  `row_click` (Funktion Zeile -> JS oder Event) macht Zeilen klickbar; `row_id` liefert die id
  (nötig für `phx-update="stream"` mit `rows={@streams.x}`).
  """
  attr :id, :string, default: nil
  attr :rows, :any, required: true
  attr :row_id, :any, default: nil
  attr :row_click, :any, default: nil
  attr :row_item, :any, default: &Function.identity/1
  attr :empty, :string, default: "Keine Einträge."
  attr :empty_icon, :string, default: "inbox"
  attr :class, :any, default: nil

  slot :col, required: true do
    attr :label, :string
    attr :class, :any
    attr :align, :string
  end

  slot :action, doc: "Aktionen in einer letzten Spalte, rechtsbündig"

  def table(assigns) do
    assigns =
      with %{rows: %Phoenix.LiveView.LiveStream{}} <- assigns do
        assign(assigns, row_id: assigns.row_id || fn {id, _item} -> id end)
      end

    ~H"""
    <div class={["relative w-full overflow-x-auto", @class]}>
      <table class="w-full text-sm">
        <thead>
          <tr class="border-b">
            <th
              :for={col <- @col}
              class={[
                "h-12 px-4 text-left align-middle font-medium whitespace-nowrap text-muted-foreground",
                col[:align] == "right" && "text-right",
                col[:class]
              ]}
            >
              {col[:label]}
            </th>
            <th :if={@action != []} class="h-12 px-4">
              <span class="sr-only">Aktionen</span>
            </th>
          </tr>
        </thead>
        <tbody
          id={@id}
          phx-update={is_struct(@rows, Phoenix.LiveView.LiveStream) && "stream"}
          class="[&_tr:last-child]:border-0"
        >
          <tr
            :for={row <- @rows}
            id={@row_id && @row_id.(row)}
            class={["border-b transition-colors hover:bg-muted/50", @row_click && "cursor-pointer"]}
          >
            <td
              :for={col <- @col}
              phx-click={@row_click && @row_click.(row)}
              class={[
                "px-4 py-3 align-middle",
                col[:align] == "right" && "text-right tabular-nums",
                col[:class]
              ]}
            >
              {render_slot(col, @row_item.(row))}
            </td>
            <td :if={@action != []} class="px-4 py-3 text-right align-middle whitespace-nowrap">
              <div class="inline-flex items-center justify-end gap-1">
                <%= for action <- @action do %>
                  {render_slot(action, @row_item.(row))}
                <% end %>
              </div>
            </td>
          </tr>
          <tr :if={not is_struct(@rows, Phoenix.LiveView.LiveStream) and Enum.empty?(@rows)}>
            <td colspan={length(@col) + if(@action != [], do: 1, else: 0)}>
              <.empty_state icon={@empty_icon}>{@empty}</.empty_state>
            </td>
          </tr>
        </tbody>
      </table>
    </div>
    """
  end

  @doc "Leerer Zustand: Icon, ein Satz, optional eine Aktion."
  attr :icon, :string, default: "inbox"
  attr :class, :any, default: nil
  slot :inner_block, required: true
  slot :action

  def empty_state(assigns) do
    ~H"""
    <div class={["flex flex-col items-center py-8 text-center text-sm text-muted-foreground", @class]}>
      <.icon name={@icon} class="mb-3 h-12 w-12 opacity-50" />
      <p>{render_slot(@inner_block)}</p>
      <div :if={@action != []} class="mt-4">{render_slot(@action)}</div>
    </div>
    """
  end

  @doc """
  Seitenwechsel: „n Einträge · Seite x von y“ mit Zurück/Weiter. `path` ist eine Funktion
  Seitenzahl -> Pfad; mit `patch` werden LiveView-Patches statt Links erzeugt.
  """
  attr :page, :integer, required: true
  attr :total, :integer, required: true
  attr :per_page, :integer, required: true
  attr :path, :any, required: true
  attr :patch, :boolean, default: false
  attr :class, :any, default: nil

  def pager(assigns) do
    assigns = assign(assigns, :pages, max(1, ceil_div(assigns.total, assigns.per_page)))

    ~H"""
    <div class={[
      "flex flex-wrap items-center justify-between gap-2 text-sm text-muted-foreground",
      @class
    ]}>
      <span>{Format.number(@total)} Einträge · Seite {@page} von {@pages}</span>
      <div class="flex gap-2">
        <.pager_button disabled={@page <= 1} path={@path.(@page - 1)} patch={@patch}>
          Zurück
        </.pager_button>
        <.pager_button disabled={@page >= @pages} path={@path.(@page + 1)} patch={@patch}>
          Weiter
        </.pager_button>
      </div>
    </div>
    """
  end

  attr :disabled, :boolean, required: true
  attr :path, :string, required: true
  attr :patch, :boolean, required: true
  slot :inner_block, required: true

  defp pager_button(%{disabled: true} = assigns) do
    ~H"""
    <.button variant="outline" size="sm" disabled>{render_slot(@inner_block)}</.button>
    """
  end

  defp pager_button(%{patch: true} = assigns) do
    ~H"""
    <.button variant="outline" size="sm" patch={@path}>{render_slot(@inner_block)}</.button>
    """
  end

  defp pager_button(assigns) do
    ~H"""
    <.button variant="outline" size="sm" href={@path}>{render_slot(@inner_block)}</.button>
    """
  end

  defp ceil_div(_, per_page) when per_page <= 0, do: 1
  defp ceil_div(total, per_page), do: div(total + per_page - 1, per_page)

  @doc "Beschreibungsliste für Stammdaten: Label links, Wert rechts."
  attr :class, :any, default: nil

  slot :item, required: true do
    attr :label, :string, required: true
  end

  def kv_list(assigns) do
    ~H"""
    <dl class={["divide-y text-sm", @class]}>
      <div
        :for={item <- @item}
        class="flex flex-wrap items-start justify-between gap-x-4 gap-y-1 py-2.5"
      >
        <dt class="text-muted-foreground">{item.label}</dt>
        <dd class="text-right font-medium">{render_slot(item)}</dd>
      </div>
    </dl>
    """
  end

  ## Tabs

  @doc """
  Tab-Leiste aus Links. Der aktive Tab kommt vom Server (z. B. aus `?tab=`), deshalb ohne JS;
  in LiveViews mit `patch`, sonst mit `href`.

      <.tabs>
        <:tab label="Profil" patch={"/admin/users/\#{@user.id}?tab=profile"} active={@tab == "profile"} />
      </.tabs>
  """
  attr :class, :any, default: nil

  slot :tab, required: true do
    attr :label, :string, required: true
    attr :href, :string
    attr :patch, :string
    attr :navigate, :string
    attr :active, :boolean
    attr :count, :integer
  end

  def tabs(assigns) do
    ~H"""
    <nav
      class={[
        "inline-flex h-10 max-w-full items-center gap-1 overflow-x-auto rounded-md bg-muted p-1 text-muted-foreground",
        @class
      ]}
      role="tablist"
    >
      <.link
        :for={tab <- @tab}
        href={tab[:href]}
        patch={tab[:patch]}
        navigate={tab[:navigate]}
        role="tab"
        aria-selected={to_string(tab[:active] == true)}
        class={[
          "inline-flex h-8 items-center justify-center gap-1.5 rounded-sm px-3 text-sm font-medium whitespace-nowrap transition-colors",
          tab[:active] && "bg-background text-foreground shadow-xs",
          !tab[:active] && "hover:text-foreground"
        ]}
      >
        {tab.label}
        <span :if={is_integer(tab[:count])} class="text-xs text-muted-foreground">
          {Format.number(tab.count)}
        </span>
      </.link>
    </nav>
    """
  end

  ## Dialog

  @doc """
  Modaler Dialog auf Basis von `<dialog>`.

  In LiveViews gehört der Zustand dem Server: `open={@dialog == "password"}` öffnet ihn, der
  Hook `DfsUiDialog` ruft `showModal()`; Escape, Klick auf den Hintergrund und der
  Schließen-Knopf senden das Event `on_close` (Standard `"close_dialog"`) mit `id`.
  In normalen Seiten öffnet ein Element mit `data-dialog-open="id"` den Dialog, geschlossen
  wird mit `data-dialog-close`.

      <.dialog id="password" title="Neues Passwort setzen" open={@dialog == "password"}>
        <.form ...> ... </.form>
        <:footer><.button type="submit" form="password-form">Speichern</.button></:footer>
      </.dialog>
  """
  attr :id, :string, required: true
  attr :title, :string, required: true
  attr :description, :string, default: nil
  attr :open, :boolean, default: false
  attr :on_close, :string, default: "close_dialog"
  attr :size, :string, default: "md", values: ~w(sm md lg)
  attr :class, :any, default: nil
  attr :rest, :global, include: ~w(phx-target)
  slot :inner_block, required: true
  slot :footer

  def dialog(assigns) do
    ~H"""
    <dialog
      id={@id}
      phx-hook="DfsUiDialog"
      data-open={to_string(@open)}
      data-on-close={@on_close}
      class={[
        "dfs-dialog w-full rounded-lg border bg-card p-0 text-card-foreground shadow-lg",
        @size == "sm" && "max-w-sm",
        @size == "md" && "max-w-lg",
        @size == "lg" && "max-w-2xl",
        @class
      ]}
      aria-labelledby={"#{@id}-title"}
      {@rest}
    >
      <div class="flex flex-col gap-4 p-6">
        <div class="flex items-start justify-between gap-4">
          <div class="space-y-1.5">
            <h2 id={"#{@id}-title"} class="text-lg leading-none font-semibold">{@title}</h2>
            <p :if={@description} class="text-sm text-muted-foreground">{@description}</p>
          </div>
          <button
            type="button"
            class="-m-2 rounded-md p-2 text-muted-foreground hover:text-foreground"
            aria-label="Schließen"
            phx-click={@on_close}
            phx-value-id={@id}
            data-dialog-close
          >
            <.icon name="x" class="h-4 w-4" />
          </button>
        </div>
        <div class="flex flex-col gap-4">{render_slot(@inner_block)}</div>
        <div :if={@footer != []} class="flex flex-col-reverse gap-2 sm:flex-row sm:justify-end">
          {render_slot(@footer)}
        </div>
      </div>
    </dialog>
    """
  end

  ## Dropdown-Menü

  @doc """
  Aufklappmenü auf Basis von `<details>` (ohne JS lauffähig; `dfs_ui.js` schließt es bei Klick
  außerhalb). In LiveViews bewahrt `dfsUiDom` (LiveSocket-Option `dom`) den Zustand `open`
  über Patches hinweg.

      <.dropdown_menu id="profile-menu" side="top">
        <:trigger>…</:trigger>
        <.menu_item href="/konto" icon="user">Mein Konto</.menu_item>
        <.menu_item href="/abmelden" method="delete" icon="log-out" variant="destructive">Abmelden</.menu_item>
      </.dropdown_menu>
  """
  attr :id, :string, required: true
  attr :side, :string, default: "bottom", values: ~w(top bottom right)
  attr :align, :string, default: "start", values: ~w(start end)
  attr :class, :any, default: nil
  attr :menu_class, :any, default: nil
  slot :trigger, required: true
  slot :inner_block, required: true

  def dropdown_menu(assigns) do
    ~H"""
    <details id={@id} class={["dfs-menu relative", @class]}>
      <summary class="list-none cursor-pointer [&::-webkit-details-marker]:hidden">
        {render_slot(@trigger)}
      </summary>
      <div
        class={[
          "dfs-menu-panel absolute z-50 min-w-[14rem] rounded-md border bg-popover p-1 text-popover-foreground shadow-md",
          @side == "bottom" && "top-full mt-2",
          @side == "top" && "bottom-full mb-2",
          @side == "right" && "left-full top-0 ml-2",
          @side != "right" && @align == "start" && "left-0",
          @side != "right" && @align == "end" && "right-0",
          @menu_class
        ]}
        role="menu"
      >
        {render_slot(@inner_block)}
      </div>
    </details>
    """
  end

  @doc "Überschrift im Menü (z. B. Name und E-Mail)."
  attr :class, :any, default: nil
  slot :inner_block, required: true

  def menu_label(assigns) do
    ~H"""
    <div class={["px-2 py-1.5 text-sm", @class]}>{render_slot(@inner_block)}</div>
    <div class="-mx-1 my-1 h-px bg-border"></div>
    """
  end

  @doc "Menüpunkt als Link (`href`/`navigate`/`patch`, optional `method`) oder Button."
  attr :href, :string, default: nil
  attr :navigate, :string, default: nil
  attr :patch, :string, default: nil
  attr :method, :string, default: nil
  attr :icon, :string, default: nil
  attr :variant, :string, default: "default", values: ~w(default destructive)
  attr :class, :any, default: nil
  attr :rest, :global
  slot :inner_block, required: true

  def menu_item(assigns) do
    assigns =
      assign(assigns, :classes, [
        "flex w-full cursor-pointer items-center gap-2 rounded-sm px-2 py-1.5 text-left text-sm outline-none hover:bg-accent hover:text-accent-foreground focus-visible:bg-accent [&_svg]:size-4 [&_svg]:text-muted-foreground",
        assigns.variant == "destructive" &&
          "text-destructive hover:bg-destructive/10 hover:text-destructive [&_svg]:text-destructive",
        assigns.class
      ])

    ~H"""
    <%= if @href || @navigate || @patch do %>
      <.link
        href={@href}
        navigate={@navigate}
        patch={@patch}
        method={@method}
        role="menuitem"
        class={@classes}
        {@rest}
      >
        <.icon :if={@icon} name={@icon} />
        {render_slot(@inner_block)}
      </.link>
    <% else %>
      <button type="button" role="menuitem" class={@classes} {@rest}>
        <.icon :if={@icon} name={@icon} />
        {render_slot(@inner_block)}
      </button>
    <% end %>
    """
  end

  ## Avatar

  @doc "Avatar mit Initialen (aus `user`: name/first_name/last_name/email)."
  attr :user, :map, required: true
  attr :size, :string, default: "md", values: ~w(sm md lg)
  attr :class, :any, default: nil

  def avatar(assigns) do
    ~H"""
    <span
      class={[
        "flex shrink-0 select-none items-center justify-center rounded-full bg-tone-brand-bg font-semibold text-tone-brand-fg",
        @size == "sm" && "size-6 text-xs",
        @size == "md" && "size-9 text-sm",
        @size == "lg" && "size-12 text-base",
        @class
      ]}
      aria-hidden="true"
    >
      {Format.initials(@user)}
    </span>
    """
  end

  ## Sonstiges

  @doc "Trennlinie."
  attr :class, :any, default: nil

  def separator(assigns) do
    ~H"""
    <div class={["h-px w-full bg-border", @class]} role="separator"></div>
    """
  end

  @doc "Kurzer Code-Wert zum Kopieren (z. B. ein Schlüssel)."
  attr :class, :any, default: nil
  slot :inner_block, required: true

  def code(assigns) do
    ~H"""
    <code class={["rounded bg-muted px-1.5 py-0.5 font-mono text-xs select-all", @class]}>
      {render_slot(@inner_block)}
    </code>
    """
  end

  # In HEEx steht `@name` für Assigns, deshalb Modulattribute über Funktionen auflösen.
  defp tone_class(tone, variant), do: @tone_classes[tone][variant]
  defp value_tone(tone), do: @value_tones[tone]
  defp alert_class(variant), do: @alert_classes[variant]
  defp alert_icon(variant), do: @alert_icons[variant]
end
