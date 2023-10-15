defmodule PatientFirst.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      PatientFirstWeb.Telemetry,
      PatientFirst.Repo,
      {DNSCluster, query: Application.get_env(:patient_first, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: PatientFirst.PubSub},
      # Start the Finch HTTP client for sending emails
      {Finch, name: PatientFirst.Finch},
      {Cachex, name: :patient_first},
      # Start a worker by calling: PatientFirst.Worker.start_link(arg)
      # {PatientFirst.Worker, arg},
      # Start to serve requests, typically the last entry
      PatientFirstWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: PatientFirst.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    PatientFirstWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
