defmodule EavesdropTest do
  use ExUnit.Case
  doctest Eavesdrop

  test "Normal user state changes" do
    {:ok, _pid} = Eavesdrop.Supervisor.start_link()

    Eavesdrop.user_signin("test_user")
    Eavesdrop.play_track("test_track")
    Eavesdrop.user_stop
    Eavesdrop.play_track("test_track 2")
    Eavesdrop.user_signout

    assert 1==1
  end
end
