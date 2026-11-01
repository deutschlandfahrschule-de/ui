# Changelog

## v0.2.0 – 2026-11-01

Lücken aus der Umstellung von lms-service-v2 und questions-service geschlossen:

- 33 weitere Lucide-Icons (u. a. `heart`, `arrow-up`/`-down`, `book-open-text`, `brain`, `circle`, `code`,
  `list-checks`, `list-tree`, `map`, `route`, `signpost`, `sparkles`, `table`, `video`, `wand`).
- Neue Bausteine: `form_field`, `field_errors`, `form_errors` (Ecto als optionale Abhängigkeit
  für verschachtelte Fehler), `textarea`, `checkbox`, `upload_input`/`upload_error`, `chip`,
  `progress`, `code_block`; `error` mit `compact`, `input` mit `compact_errors`.
- `input` ohne `value`, `name` oder `options` stürzt nicht mehr ab.
- `translate_error` verträgt Ecto-Optionen mit Tupeln (`{:array, :string}`), Workaround in den
  Apps entfällt.
- `DfsUi.Layouts.admin`: Navigationsgruppen mit `group_icon` sind aufklappbar (Icon, Name, Pfeil;
  offen, wenn sie den aktiven Eintrag enthalten).
- Textarea in `input` vertikal veränderbar.

## v0.1.2 – 2026-10-31

Admin-Shell: die E-Mail des Nutzers steht nur noch im Profilblock der Sidebar, nicht mehr
zusätzlich rechts in der Kopfzeile.

## v0.1.1 – 2026-10-31

Erste nutzbare Fassung nach dem Umbau des identity-service: `dfsUiDom` bewahrt `open` von
Dialog und Details über LiveView-Patches, Dialog-Hook schließt sauber aus dem Top-Layer,
Styleguide mit CSRF-Meta, Profilmenü bei eingeklappter Sidebar rechts daneben.

## v0.1.0 – 2026-10-31

Erste Fassung: Tokens, Tailwind-Theme, `dfs_ui.css`, Open Sans, Logo, Lucide-Icons,
`DfsUi.Components`, `DfsUi.Layouts` (admin, auth, topbar, head), `DfsUi.Format`,
`DfsUi.Tones`, `dfs_ui.js` (Dialog-Hook, Sidebar, Menüs) und Styleguide.
Erster Nutzer: identity-service.
