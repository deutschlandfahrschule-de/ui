defmodule DfsUi.Format do
  @moduledoc "Zahlen, Zeiten und Namen im deutschen Format für die Oberfläche."

  @doc "Ganzzahl mit Tausenderpunkt: 2290 -> \"2.290\"."
  def number(nil), do: "–"

  def number(int) when is_integer(int) do
    int
    |> Integer.to_string()
    |> String.reverse()
    |> String.graphemes()
    |> Enum.chunk_every(3)
    |> Enum.map_join(".", &Enum.join/1)
    |> String.reverse()
  end

  def number(other), do: to_string(other)

  @doc "Datum als TT.MM.JJJJ (auch aus DateTime oder ISO-String)."
  def date(nil), do: "–"
  def date(%Date{} = d), do: Calendar.strftime(d, "%d.%m.%Y")
  def date(%DateTime{} = dt), do: dt |> local() |> Calendar.strftime("%d.%m.%Y")
  def date(%NaiveDateTime{} = dt), do: Calendar.strftime(dt, "%d.%m.%Y")

  def date(str) when is_binary(str) do
    case Date.from_iso8601(str) do
      {:ok, d} -> date(d)
      _ -> parse_datetime(str, &date/1)
    end
  end

  @doc """
  Zeitpunkt als TT.MM.JJJJ HH:MM in deutscher Zeit, sofern eine Zeitzonen-Datenbank konfiguriert
  ist (z. B. `tz`); sonst in UTC mit Zusatz.
  """
  def datetime(nil), do: "–"

  def datetime(%DateTime{} = dt) do
    case DateTime.shift_zone(dt, "Europe/Berlin") do
      {:ok, local} -> Calendar.strftime(local, "%d.%m.%Y %H:%M")
      _ -> Calendar.strftime(dt, "%d.%m.%Y %H:%M") <> " UTC"
    end
  end

  def datetime(%NaiveDateTime{} = dt), do: Calendar.strftime(dt, "%d.%m.%Y %H:%M")
  def datetime(str) when is_binary(str), do: parse_datetime(str, &datetime/1)

  defp local(%DateTime{} = dt) do
    case DateTime.shift_zone(dt, "Europe/Berlin") do
      {:ok, local} -> local
      _ -> dt
    end
  end

  defp parse_datetime(str, fun) do
    case DateTime.from_iso8601(str) do
      {:ok, dt, _} -> fun.(dt)
      _ -> str
    end
  end

  @doc "Dateigröße lesbar."
  def bytes(nil), do: "–"
  def bytes(n) when n < 1024, do: "#{n} B"
  def bytes(n) when n < 1024 * 1024, do: "#{Float.round(n / 1024, 1)} KB"
  def bytes(n), do: "#{Float.round(n / 1024 / 1024, 1)} MB"

  @doc "Beschriftung aus einer Map, sonst der Schlüssel selbst; nil ergibt „–“."
  def label(_map, nil), do: "–"
  def label(_map, ""), do: "–"
  def label(map, key), do: Map.get(map, to_string(key), to_string(key))

  @doc "Name eines Nutzers (Map oder Struct mit name/first_name/last_name/email), sonst E-Mail."
  def display_name(%{name: name}) when is_binary(name) and name != "", do: name

  def display_name(%{first_name: f, last_name: l} = user) do
    case [f, l] |> Enum.reject(&(is_nil(&1) or &1 == "")) |> Enum.join(" ") do
      "" -> Map.get(user, :email) || "–"
      name -> name
    end
  end

  def display_name(%{email: email}) when is_binary(email), do: email
  def display_name(_), do: "–"

  @doc "Initialen für den Avatar: zwei Buchstaben aus dem Namen, sonst der erste der E-Mail."
  def initials(user) do
    case display_name(user) do
      "–" ->
        "?"

      name ->
        if String.contains?(name, "@") do
          name |> String.first() |> String.upcase()
        else
          name
          |> String.split(~r/\s+/, trim: true)
          |> Enum.map(&String.first/1)
          |> Enum.join()
          |> String.upcase()
          |> String.slice(0, 2)
        end
    end
  end

  @doc "Kurzform einer UUID: die ersten acht Zeichen mit Auslassung."
  def short_id(nil), do: "–"
  def short_id(id) when is_binary(id), do: String.slice(id, 0, 8) <> "…"
end
