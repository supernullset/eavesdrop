defmodule EavesdropOTPTest do
  use ExUnit.Case
  doctest EavesdropOTP.Worker
  doctest EavesdropOTP.WorkerSupervisor
  doctest EavesdropOTP.MusicService
  doctest EavesdropOTP.Supervisor

  test "Normal user state changes" do
    test_user = "test_user"

    EavesdropOTP.Supervisor.start_child(test_user)
    EavesdropOTP.Worker.play_track(test_user, "test_track")
    EavesdropOTP.Worker.stop_track(test_user)
    EavesdropOTP.Worker.play_track(test_user, "test_track 2")
    EavesdropOTP.Worker.signout(test_user)

    assert 1==1
  end
end
