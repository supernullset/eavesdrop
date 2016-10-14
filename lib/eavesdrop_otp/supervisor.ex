defmodule EavesdropOTP.Supervisor do
  use Supervisor

  def start_link do
    Supervisor.start_link(__MODULE__, nil, name: :eavesdrop_worker_supervisor)
  end

  def start_child(user_name) do
    Supervisor.start_child(:eavesdrop_worker_supervisor, [user_name])
  end

  def init(_) do
    children = [
      supervisor(EavesdropOTP.WorkerSupervisor, [])
    ]
    supervise(children, strategy: :simple_one_for_one)
  end
end
