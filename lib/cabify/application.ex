defmodule Cabify.Application do
  use Application

  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    children = [
      supervisor(Cabify.Checkout, [], name: Cabify.Checkout)
    ]

    opts = [strategy: :one_for_one, name: Cabify.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
