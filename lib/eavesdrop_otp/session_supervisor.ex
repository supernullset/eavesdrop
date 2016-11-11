defmodule EavesdropOTP.SessionSupervisor do
  use Supervisor

  def start_link(user_name) do
    Supervisor.start_link(__MODULE__, [user_name], name: via_tuple(user_name))
  end

  def init(user_name) do
    processes = [
      worker(EavesdropOTP.MusicService, [user_name]),
      worker(EavesdropOTP.UserSession, [user_name]),
    ]
    supervise(processes, strategy: :one_for_one)
  end

  @doc "utility function to lookup a process in gproc"
  def via_tuple(user_name) do
    {:via, :gproc, gproc_key(user_name)}
  end

  @doc "The gproc key"
  def gproc_key(user_name) do
    {:n, :l, "#{user_name}_session_supervisor"}
  end
end
