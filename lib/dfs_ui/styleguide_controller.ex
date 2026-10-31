defmodule DfsUi.StyleguideController do
  @moduledoc """
  Liefert den Styleguide als eigenständige Seite. In der App:

      if Application.compile_env(:my_app, :dev_routes) do
        scope "/dev" do
          pipe_through :browser
          get "/styleguide", DfsUi.StyleguideController, :index
        end
      end

  Die Seite lädt `/assets/css/app.css` und `/assets/js/app.js` der App; andere Pfade über
  `config :dfs_ui, styleguide: [css_path: "...", js_path: "..."]`.
  """
  use Phoenix.Controller, formats: [:html]

  def index(conn, _params) do
    opts = Application.get_env(:dfs_ui, :styleguide, [])

    assigns = %{
      css_path: Keyword.get(opts, :css_path, "/assets/css/app.css"),
      js_path: Keyword.get(opts, :js_path, "/assets/js/app.js"),
      app_name: Keyword.get(opts, :app_name, "App"),
      csrf_token: Plug.CSRFProtection.get_csrf_token()
    }

    body =
      assigns
      |> DfsUi.Styleguide.document()
      |> Phoenix.HTML.Safe.to_iodata()

    conn
    |> put_root_layout(false)
    |> put_layout(false)
    |> html(body)
  end
end
