defmodule EavesdropOTP.Worker do
  @moduledoc "A module which represents the current actions of a user
  on the system. The FSM can be in 1 of 3 states at any given time:
  signin, idle, or play. This module defines the actions which take
  each state to the others"

  @doc "Kicks off a user process"
  def start_link(user_name) do
    :gen_fsm.start_link(
      via_tuple(user_name), # NameScope
      __MODULE__, # Module
      user_name,  # arguments to pass to init
      []
    )
  end

  @doc "
  Puts the FSM in its initial state and traps exits for loud errors

  service is a callback module responsible for handling actual calls
  and changes on a theoretical server
  "
  def init(user_name) do
    EavesdropOTP.MusicService.signin(user_name)
    Process.flag(:trap_exit, true)

    {:ok, :play, user_name}
  end

  #External functions

  @doc "External interaction functions"
  def play_track(user_name, track) do
    :gen_fsm.sync_send_event(via_tuple(user_name), {:play, track})
  end
  def stop_track(user_name) do
    :gen_fsm.sync_send_event(via_tuple(user_name), :stop)
  end
  def signout(user_name) do
    :gen_fsm.stop(via_tuple(user_name))
  end

  def via_tuple(user_name) do
    {:via, :gproc, {:n, :l, "#{user_name}_worker"}}
  end

  # FSM Server functions
  @doc "Defines a handler for receiving messages while in the _idle_ state"
  def idle(:idle, _from, user_name) do
    {:next_state, :play, user_name}
  end
  def idle({:play, track}, _from, user_name) do
    EavesdropOTP.MusicService.play(user_name, track)

    {:next_state, :play, user_name}
  end
  def idle(_any, _from, user_name) do
    EavesdropOTP.MusicService.idle(user_name)

    {:next_state, :idle, user_name}
  end

  @doc "Defines messages for receiving messages while on the _play_ state"
  def play({:play, track}, _from, user_name) do
    EavesdropOTP.MusicService.play(user_name, track)

    {:next_state, :play, user_name}
  end
  def play(:stop, _from, user_name) do
    EavesdropOTP.MusicService.idle(user_name)

    {:next_state, :idle, user_name}
  end
  def play(_any, _from, user_name) do
    EavesdropOTP.MusicService.idle(user_name)

    {:next_state, :idle, user_name}
  end

  def terminate(reason, _state_name, user_name) do
    EavesdropOTP.MusicService.shutdown(user_name, reason)
  end
end
