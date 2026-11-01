defmodule DfsUiTest.Course do
  use Ecto.Schema
  import Ecto.Changeset

  embedded_schema do
    field(:title, :string)

    embeds_many :lessons, Lesson do
      field(:name, :string)
    end
  end

  def changeset(params) do
    %__MODULE__{}
    |> cast(params, [:title])
    |> validate_required([:title])
    |> cast_embed(:lessons, with: &lesson_changeset/2)
  end

  defp lesson_changeset(lesson, params) do
    lesson |> cast(params, [:name]) |> validate_required([:name])
  end
end

defmodule DfsUiTest do
  use ExUnit.Case, async: true
  import Phoenix.LiveViewTest, only: [render_component: 2, rendered_to_string: 1]
  import Phoenix.Component, only: [sigil_H: 2]
  import DfsUi.Components

  test "button rendert Link oder Button" do
    assert render_component(&button/1, href: "/x", inner_block: block("Los")) =~ ~s(<a href="/x")
    assert render_component(&button/1, inner_block: block("Los")) =~ ~s(<button type="button")
  end

  test "status_badge kennt Tone und Beschriftung" do
    html = render_component(&status_badge/1, status: "revoked")
    assert html =~ "Widerrufen"
    assert html =~ "bg-tone-danger-bg"
  end

  test "input zeigt Fehler" do
    html = render_component(&input/1, id: "e", name: "email", value: "", errors: ["fehlt"])
    assert html =~ "fehlt"
    assert html =~ ~s(aria-invalid="true")
  end

  test "table mit leerem Zustand" do
    assigns = %{}

    html =
      rendered_to_string(~H"""
      <.table rows={[]} empty="Nichts da.">
        <:col :let={r} label="Name">{r}</:col>
      </.table>
      """)

    assert html =~ "Nichts da."
  end

  test "Styleguide rendert vollständig" do
    html = rendered_to_string(DfsUi.Styleguide.document(%{}))
    assert html =~ "Styleguide"
    assert html =~ "Mein Konto"
  end

  test "Format" do
    assert DfsUi.Format.number(1_234_567) == "1.234.567"
    assert DfsUi.Format.date(~D[2026-10-31]) == "31.10.2026"
    assert DfsUi.Format.initials(%{name: "Ada Admin"}) == "AA"
    assert DfsUi.Format.initials(%{email: "x@y.de"}) == "X"

    assert DfsUi.Format.display_name(%{first_name: "Max", last_name: nil, email: "m@x.de"}) ==
             "Max"
  end

  test "input ohne value, name oder options stürzt nicht ab" do
    assert render_component(&input/1, id: "q", name: "q") =~ ~s(id="q")
    assert render_component(&input/1, id: "t", type: "textarea") =~ "<textarea"
    assert render_component(&input/1, id: "s", name: "s", type: "select") =~ "<select"
    assert render_component(&input/1, id: "c", name: "c", type: "checkbox") =~ ~s(type="checkbox")
  end

  test "translate_error verträgt Optionen mit Tupeln und setzt nur vorhandene Platzhalter ein" do
    assert translate_error({"is invalid", [type: {:array, :string}, validation: :cast]}) ==
             "is invalid"

    assert translate_error({"should be at least %{count} character(s)", count: 3, kind: :min}) ==
             "should be at least 3 character(s)"

    assert translate_error({"%{type} %{unknown}", type: {:array, :string}}) ==
             "{:array, :string} %{unknown}"
  end

  test "form_field zeigt Fehler klein mit Icon, field_errors einzeln" do
    form = Phoenix.Component.to_form(%{"title" => ""}, as: :x, errors: [title: {"fehlt", []}])
    html = render_component(&form_field/1, field: form[:title], label: "Titel")
    assert html =~ "fehlt"
    assert html =~ "text-xs text-destructive"
    assert html =~ ~s(aria-invalid="true")

    html = render_component(&form_field/1, field: form[:title], type: "textarea", rows: 3)
    assert html =~ ~s(rows="3")

    html =
      render_component(&form_field/1,
        field: form[:kind],
        type: "select",
        options: [{"A", "a"}],
        prompt: "Bitte wählen"
      )

    assert html =~ "Bitte wählen"
    assert render_component(&field_errors/1, field: form[:title]) =~ "fehlt"
  end

  test "form_errors fasst Changeset-Fehler zusammen, auch verschachtelte" do
    changeset =
      DfsUiTest.Course.changeset(%{"title" => "", "lessons" => [%{"name" => ""}]})
      |> Map.put(:action, :insert)

    html =
      render_component(&form_errors/1,
        form: changeset_form(changeset),
        labels: %{title: "Titel"}
      )

    assert html =~ "Titel: can&#39;t be blank"
    assert html =~ "lessons › Nr. 1 › name: can&#39;t be blank"

    # ohne action (noch nicht gespeichert) keine Box
    unsaved = DfsUiTest.Course.changeset(%{"title" => ""})
    refute render_component(&form_errors/1, form: changeset_form(unsaved)) =~ "role"
  end

  test "textarea und checkbox ohne FormField" do
    assert render_component(&textarea/1, id: "n", name: "note", value: "Hallo") =~
             "Hallo</textarea>"

    html = render_component(&checkbox/1, id: "i", name: "ids[]", value: "7", hidden_false: false)
    assert html =~ ~s(value="7")
    refute html =~ ~s(value="false")
    assert render_component(&checkbox/1, id: "a", name: "a", checked: true) =~ "checked"
  end

  test "chip als Link oder Button mit Zähler" do
    html =
      render_component(&chip/1, patch: "/x", active: true, count: 1200, inner_block: block("A"))

    assert html =~ ~s(href="/x")
    assert html =~ "1.200"

    html = render_component(&chip/1, tone: "danger", count: 2, inner_block: block("B"))
    assert html =~ "<button"
    assert html =~ "bg-tone-danger-bg"
  end

  test "progress begrenzt auf 0–100 %" do
    assert render_component(&progress/1, value: 3, max: 4) =~ "75 %"
    assert render_component(&progress/1, value: 250) =~ "width: 100%"
    assert render_component(&progress/1, value: nil) =~ "width: 0%"
  end

  test "code_block" do
    assert render_component(&code_block/1, text: "a < b") =~ "a &lt; b</pre>"
  end

  test "upload_input mit Datei und Fehler" do
    conf =
      Phoenix.LiveView.UploadConfig.build(:csv, "up", accept: ~w(.csv), max_file_size: 1024)

    entry = %Phoenix.LiveView.UploadEntry{ref: "0", upload_ref: "up", client_name: "a.csv"}
    conf = %{conf | entries: [entry], errors: [{"0", :not_accepted}]}

    html = render_component(&upload_input/1, upload: conf, label: "Datei")
    assert html =~ "a.csv"
    assert html =~ "Dieser Dateityp ist nicht erlaubt (erlaubt: .csv)."
    assert upload_error(:too_large, conf) == "Die Datei ist zu groß (höchstens 1.0 KB)."
  end

  test "Admin-Shell: Gruppen mit group_icon sind aufklappbar, offen beim aktiven Eintrag" do
    nav = [
      %{label: "Start", icon: "home", href: "/"},
      %{
        label: "Kurse",
        icon: "graduation-cap",
        href: "/k",
        group: "Inhalte",
        group_icon: "book-open"
      },
      %{
        label: "Videos",
        icon: "video",
        href: "/v",
        group: "Inhalte",
        group_icon: "book-open",
        active: true
      },
      %{label: "KI", icon: "brain", href: "/ki", group: "KI", group_icon: "sparkles"},
      %{label: "Protokoll", icon: "activity", href: "/p", group: "System"}
    ]

    html =
      render_component(&DfsUi.Layouts.admin/1, flash: %{}, nav: nav, inner_block: block("x"))

    assert html =~ ~r/<details class="dfs-nav-group group\/nav" open/
    assert length(Regex.scan(~r/<details class="dfs-nav-group/, html)) == 2
    # Gruppe ohne group_icon bleibt Überschrift
    assert html =~ ~r/uppercase">\s*System/
  end

  test "alle Icons der Apps sind in der Bibliothek" do
    for name <-
          ~w(arrow-down book-open-text brain circle code list-tree route signpost table trash video wand) do
      assert DfsUi.Icons.known?(name), name
    end
  end

  defp block(text), do: [%{inner_block: fn _, _ -> text end}]

  # Ohne phoenix_ecto: Formular direkt aus dem Changeset (form_errors liest nur `source`).
  defp changeset_form(changeset), do: %Phoenix.HTML.Form{source: changeset, name: "course"}

  describe "Versionskennung der Dateien unter /ui" do
    test "asset_path hängt die Version an" do
      assert DfsUi.asset_path("/images/logo.svg") == "/ui/images/logo.svg?vsn=#{DfsUi.version()}"

      assert DfsUi.asset_path("/images/logo.svg", "/static/ui") ==
               "/static/ui/images/logo.svg?vsn=#{DfsUi.version()}"
    end

    test "Kopf und Layouts nutzen die Kennung" do
      head = render_component(&DfsUi.Layouts.head/1, %{})
      assert head =~ ~s(href="/ui/images/favicon.svg?vsn=#{DfsUi.version()}")
      assert head =~ ~s(href="/ui/images/apple-touch-icon.png?vsn=#{DfsUi.version()}")

      auth =
        render_component(&DfsUi.Layouts.auth/1, %{
          flash: %{},
          inner_block: [%{__slot__: :inner_block, inner_block: fn _, _ -> "Inhalt" end}]
        })

      assert auth =~ ~s(src="/ui/images/logo.svg?vsn=#{DfsUi.version()}")
    end

    test "Schriften im Stylesheet tragen die aktuelle Version" do
      css = File.read!(Path.expand("../priv/static/css/dfs_ui.css", __DIR__))

      kennungen =
        Regex.scan(~r/woff2\?vsn=([0-9.]+)/, css, capture: :all_but_first) |> List.flatten()

      assert length(kennungen) == 3

      assert Enum.uniq(kennungen) == [DfsUi.version()],
             "dfs_ui.css: ?vsn= an den Schriften auf #{DfsUi.version()} setzen"
    end
  end
end
