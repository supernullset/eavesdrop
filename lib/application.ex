defmodule EavesdropOTP.Application do
  use Application

  def start(_, _) do
    EavesdropOTP.Supervisor.start_link
  end
end
