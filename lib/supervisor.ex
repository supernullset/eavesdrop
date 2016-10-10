defmodule EavesdropOTP.Supervisor do
  use Supervisor

  def start_link do
    Supervisor.start_link(__MODULE__, nil, name: :eavesdrop_worker_supervisor)
  end

  def start_child(user_name) do
    Supervisor.start_child(:eavesdrop_worker_supervisor, [user_name])
  end

  def init(user_name) do
    children = [
      worker(GenEvent, [[name: via_manager(user_name)]]),
      worker(EavesdropOTP.Worker, [user_name]),
    ]

    supervise(children, strategy: :simple_one_for_one)
  end

  def via_manager(user_name) do
    {:via, :gproc, {:n, :l, {GenEvent, user_name}}}
  end
end
