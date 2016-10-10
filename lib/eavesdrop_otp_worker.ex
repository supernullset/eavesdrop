defmodule EavesdropOTP.Worker do
  @moduledoc "A module which represents the current actions of a user
  on the system. The FSM can be in 1 of 3 states at any given time:
  signin, idle, or play. This module defines the actions which take
  each state to the others"

  @doc "Kicks off a user process"
  def start_link(user_name) do
    :gen_fsm.start_link(
      {:via, :gproc, {:n, :l, {__MODULE__, user_name}}}, #NameScope
      user_name, # arguments to pass to init
      []
    )
  end

  @doc "
  Puts the FSM in its initial state and traps exits for loud errors

  service is a callback module responsible for handling actual calls
  and changes on a theoretical server
  "
  def init(user_name) do
    MusicService.signin(user_name)

    {:ok, :play, user_name}
  end

  #External functions

  @doc "External interaction functions"
  def play_track(user_name, track) do
    :gen_fsm.send_event(whereis(user_name), {:play, track})
  end
  def stop_track(user_name) do
    :gen_fsm.send_event(whereis(user_name), :stop)
  end
  def signout(user_name) do
    :gen_fsm.stop(whereis(user_name))
  end

  def whereis(user_name) do
    :gproc.whereis_name({:n, :l, {__MODULE__, user_name}})
  end

  # FSM Server functions
  @doc "Defines a handler for receiving messages while in the _idle_ state"
  def idle(:idle, user_name) do
    {:next_state, :play, user_name}
  end
  def idle({:play, track}, user_name) do
    MusicService.play(user_name, track)

    {:next_state, :play, user_name}
  end
  def idle(_any, user_name) do
    MusicService.idle(user_name)

    {:next_state, :idle, user_name}
  end

  @doc "Defines messages for receiving messages while on the _play_ state"
  def play({:play, track}, user_name) do
    MusicService.play(user_name, track)

    {:next_state, :play, user_name}
  end
  def play(:stop, user_name) do
    MusicService.idle(user_name)

    {:next_state, :idle, user_name}
  end
  def play(_any, user_name) do
    MusicService.idle(user_name)

    {:next_state, :idle, user_name}
  end

  def terminate(reason, _state_name, user_name) do
    MusicService.shutdown(user_name, reason)
  end
end
