defmodule EavesdropOTP.WorkerSupervisor do
  use Supervisor

  def start_link(user_name) do
    Supervisor.start_link(__MODULE__, [user_name])
  end

  def init(user_name) do
    processes = [
      worker(MusicService, [user_name]),
      worker(EavesdropOTP.Worker, [user_name]),
    ]
    supervise(processes, strategy: :one_for_one)
  end
end
