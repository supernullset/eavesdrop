defmodule EavesdropOTP.Supervisor do
  use Supervisor

  @supervisor_name :eavesdrop_supervisor

  def start_link do
    Supervisor.start_link(__MODULE__, nil, name: @supervisor_name)
  end

  def start_child(user_name) do
    Supervisor.start_child(@supervisor_name, [user_name])
  end

  def init(_) do
    children = [
      supervisor(EavesdropOTP.SessionSupervisor, [])
    ]
    supervise(children, strategy: :simple_one_for_one)
  end

  @doc "An ungraceful way to remove users from the application"
  def terminate_child(user_name) do
    pid = user_name
    |> EavesdropOTP.SessionSupervisor.gproc_key
    |> :gproc.where()

    Supervisor.terminate_child(@supervisor_name, pid)
  end
end
