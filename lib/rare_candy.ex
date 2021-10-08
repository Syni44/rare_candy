defmodule RareCandy do
  use Application
  use HTTPoison.Base

  def start(_type, _args) do
    RareCandy.Supervisor.start_link
  end
end
