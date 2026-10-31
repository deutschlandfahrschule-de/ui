defmodule DfsUi.Tones do
  @moduledoc """
  Zentrale Zuordnung von Datensatz-Status zu Tone (Farbe) und deutscher Beschriftung.
  Apps ergänzen eigene Status über die Konfiguration:

      config :dfs_ui,
        status_tones: %{"stored" => "success"},
        status_labels: %{"stored" => "gespeichert"}
  """

  @tones ~w(neutral info success warning danger brand accent)

  @status_tones %{
    "active" => "success",
    "confirmed" => "success",
    "done" => "success",
    "stored" => "success",
    "valid" => "success",
    "pending" => "info",
    "running" => "info",
    "queued" => "info",
    "disabled" => "neutral",
    "archived" => "neutral",
    "draft" => "neutral",
    "expired" => "warning",
    "revoked" => "danger",
    "failed" => "danger",
    "locked" => "danger"
  }

  @status_labels %{
    "active" => "Aktiv",
    "confirmed" => "Bestätigt",
    "done" => "Fertig",
    "stored" => "Gespeichert",
    "valid" => "Gültig",
    "pending" => "Offen",
    "running" => "Läuft",
    "queued" => "Wartet",
    "disabled" => "Deaktiviert",
    "archived" => "Archiviert",
    "draft" => "Entwurf",
    "expired" => "Abgelaufen",
    "revoked" => "Widerrufen",
    "failed" => "Fehlgeschlagen",
    "locked" => "Gesperrt"
  }

  def tones, do: @tones

  @doc "Tone zu einem Status; unbekannt ergibt neutral."
  def tone_for(status) do
    key = to_string(status)
    Map.get(configured(:status_tones), key) || Map.get(@status_tones, key, "neutral")
  end

  @doc "Deutsche Beschriftung zu einem Status; unbekannt ergibt den Status selbst."
  def label_for(status) do
    key = to_string(status)
    Map.get(configured(:status_labels), key) || Map.get(@status_labels, key, key)
  end

  defp configured(key), do: Application.get_env(:dfs_ui, key, %{})
end
