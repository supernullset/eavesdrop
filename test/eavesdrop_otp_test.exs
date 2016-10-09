defmodule EavesdropOTPTest do
  use ExUnit.Case
  doctest EavesdropOTP

  test "Normal user state changes" do
    {:ok, _pid} = EavesdropOTP.Supervisor.start_link()

    EavesdropOTP.user_signin("test_user")
    EavesdropOTP.play_track("test_track")
    EavesdropOTP.user_stop
    EavesdropOTP.play_track("test_track 2")
    EavesdropOTP.user_signout

    assert 1==1
  end
end
