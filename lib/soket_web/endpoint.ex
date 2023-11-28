defmodule SoketWeb.Endpoint do
  use Phoenix.Endpoint, otp_app: :soket

  @impl true
  def init(_, config) do
    # Using passed fds if available
    Code.ensure_all_loaded([:gen_tcp, Bandit, ThousandIsland.Transports.TCP])

    Extrace.calls(
      [
        {:gen_tcp, :listen, :_},
        {Bandit, :start_link, :_},
        {ThousandIsland.Transports.TCP, :start_link, :_}
      ],
      5
    )
    |> IO.inspect()

    passed_in_socket_conf =
      if fd = socket_file_descriptor() do
        [
          http:
            Keyword.merge(config[:http],
              ip: {0, 0, 0, 0, 0, 0, 0, 0},
              port: 0,
              thousand_island_options: [
                transport_options: [:inet6, port: 0, fd: fd, debug: true]
              ]
            )
        ]
      else
        []
      end

    {:ok, Keyword.merge(config, passed_in_socket_conf)} |> IO.inspect()
  end

  defp socket_file_descriptor do
    case :systemd.listen_fds() do
      [{fd, _} | _] when is_integer(fd) and fd > 0 -> fd
      [fd | _] when is_integer(fd) and fd > 0 -> fd
      _ -> nil
    end
  end

  # The session will be stored in the cookie and signed,
  # this means its contents can be read but not tampered with.
  # Set :encryption_salt if you would also like to encrypt it.
  @session_options [
    store: :cookie,
    key: "_soket_key",
    signing_salt: "2uTBx+Gt",
    same_site: "Lax"
  ]

  socket "/live", Phoenix.LiveView.Socket, websocket: [connect_info: [session: @session_options]]

  # Serve at "/" the static files from "priv/static" directory.
  #
  # You should set gzip to true if you are running phx.digest
  # when deploying your static files in production.
  plug Plug.Static,
    at: "/",
    from: :soket,
    gzip: false,
    only: SoketWeb.static_paths()

  # Code reloading can be explicitly enabled under the
  # :code_reloader configuration of your endpoint.
  if code_reloading? do
    socket "/phoenix/live_reload/socket", Phoenix.LiveReloader.Socket
    plug Phoenix.LiveReloader
    plug Phoenix.CodeReloader
  end

  plug Phoenix.LiveDashboard.RequestLogger,
    param_key: "request_logger",
    cookie_key: "request_logger"

  plug Plug.RequestId
  plug Plug.Telemetry, event_prefix: [:phoenix, :endpoint]

  plug Plug.Parsers,
    parsers: [:urlencoded, :multipart, :json],
    pass: ["*/*"],
    json_decoder: Phoenix.json_library()

  plug Plug.MethodOverride
  plug Plug.Head
  plug Plug.Session, @session_options
  plug SoketWeb.Router
end
