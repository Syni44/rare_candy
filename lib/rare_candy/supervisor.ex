defmodule RareCandy.Supervisor do
  use Supervisor

  def start_link do
    :supervisor.start_link(__MODULE__, [])
  end

  def init([]) do
    children = [
      RareCandy.Api
    ]

    # See http://elixir-lang.org/docs/stable/Supervisor.Behaviour.html
    # for other strategies and supported options
    {:ok, _pid} = Supervisor.start_link(children, strategy: :one_for_one)
  end
end
