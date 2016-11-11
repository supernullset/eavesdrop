defmodule EavesdropOTPTest do
  alias EavesdropOTP.UserSession

  use ExUnit.Case, async: true

  doctest EavesdropOTP.UserSession

  test "state changes" do
    user = "state_user"
    UserSession.signin(user)

    assert UserSession.last_message(user) == "Idle"
    assert UserSession.current_track(user) == nil

    UserSession.play_track(user, "test_track")
    assert UserSession.last_message(user) == "You are now listening to test_track on Rdio"
    assert UserSession.current_track(user) == "test_track"

    UserSession.stop_track(user)
    assert UserSession.last_message(user) == "Idle"
    assert UserSession.current_track(user) == nil


    UserSession.play_track(user, "test_track 2")
    assert UserSession.last_message(user) == "You are now listening to test_track 2 on Rdio"
    assert UserSession.current_track(user) == "test_track 2"

    UserSession.signout(user)
    refute UserSession.present?(user)
  end

  test "process is registered with initialization" do
    user = "init_user"
    UserSession.signin(user)

    assert UserSession.present?(user)
  end

  test "play_track updates the state" do
    user = "play_user"

    UserSession.signin(user)
    UserSession.play_track(user, "test_track")

    assert UserSession.current_track(user) == "test_track"
  end

  test "stop_track updates the state" do
    user = "stop_user"

    UserSession.signin(user)
    UserSession.play_track(user, "test_track")
    UserSession.stop_track(user)

    assert UserSession.current_track(user) == nil
    assert UserSession.last_message(user) == "Idle"
  end
end
