defmodule Eblox.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @data_providers Application.compile_env(:eblox, :data_providers, [
                    {Eblox.Data.Provider,
                     impl: Eblox.Data.Providers.FileSystem,
                     resources: %{},
                     content_dir:
                       Application.compile_env(:eblox, :content_dir, "priv/test_content")}
                  ])

  @data_taxonomies Application.compile_env(:eblox, :data_taxonomies, [
                     Supervisor.child_spec(
                       {Eblox.Data.Taxonomy, impl: Eblox.Data.Taxonomies.Comments},
                       id: Eblox.Data.Taxonomies.Comments
                     ),
                     Supervisor.child_spec(
                       {Eblox.Data.Taxonomy, impl: Eblox.Data.Taxonomies.Tags},
                       id: Eblox.Data.Taxonomies.Tags
                     )
                   ])

  @impl Application
  def start(_type, _args) do
    children = [
      # Start the Ecto repository
      Eblox.Repo,
      # Start the Telemetry supervisor
      EbloxWeb.Telemetry,
      # Start the PubSub system
      {Phoenix.PubSub, name: Eblox.PubSub},
      # Start the Endpoint (http/https)
      EbloxWeb.Endpoint,
      # Providers collect posts data and cache it
      {Eblox.Data.Providers, @data_providers},
      # Taxonomies organize posts data collected by Providers
      {Eblox.Data.Taxonomies, @data_taxonomies}
      # Start a worker by calling: Eblox.Worker.start_link(arg)
      # {Eblox.Worker, arg}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Eblox.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    EbloxWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
