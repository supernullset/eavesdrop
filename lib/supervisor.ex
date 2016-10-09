defmodule Eavesdrop.Supervisor do
  use Supervisor

  def start_link do
    IO.puts "booting the supervisor"
    Supervisor.start_link(__MODULE__, :ok)
  end

  def init(:ok) do
    children = [
      worker(GenEvent, [[name: :eavesdrop_event_manager]]),
      worker(Eavesdrop, []),
    ]

    supervise(children, strategy: :one_for_one)
  end
end
