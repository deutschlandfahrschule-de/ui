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

  defp block(text), do: [%{inner_block: fn _, _ -> text end}]
end
