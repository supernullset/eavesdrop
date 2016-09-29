defmodule Eavesdrop do

  @moduledoc "A module which represents the current actions of a user
  on the system. The FSM can be in 1 of 3 states at any given time:
  signin, idle, or play. This module defines the actions which take
  each state to the others"

  #External functions

  @doc "External interaction functions"
  def user_signin(name) do
    :gen_fsm.send_event(__MODULE__, {:signin, name})
  end
  def play_track(track) do
    :gen_fsm.send_event(__MODULE__, {:play, track})
  end
  def user_stop() do
    :gen_fsm.send_event(__MODULE__, :stop)
  end
  def user_signout() do
    :gen_fsm.send_event(__MODULE__, :signout)
  end

  # FSM Server functions

  @doc "Kicks off a user process"
  def start_link do
    :gen_fsm.start_link({:local, __MODULE__}, __MODULE__, [], [])
  end

  @doc "Puts the FSM in its initial state and traps exits for loud errors"
  def init([]) do
    Process.flag(:trap_exit, true)
    {:ok, :signin, []}
  end

  @doc "Defines a handler for receiving messages while in the _signin_ state"
  def signin({:signin, name}, _loopdata) do
    MusicService.signin(name)
    {:next_state, :play, []}
  end
  def signin(_any) do
    {:next_state, :signin, []}
  end

  @doc "Defines a handler for receiving messages while in the _idle_ state"
  def idle(:idle, _loopdata) do
    {:next_state, :play, []}
  end
  def idle({:play, track}, _loopdata) do
    MusicService.play(track)
    {:next_state, :play, []}
  end
  def idle(:signout, _loopdata) do
    MusicService.signout
    {:next_state, :signin, []}
  end

  @doc "Defines messages for receiving messages while on the _play_ state"
  def play({:play, track}, _loopdata) do
    MusicService.play(track)
    {:next_state, :play, []}
  end
  def play(:stop, _loopdata) do
    MusicService.idle
    {:next_state, :idle, []}
  end
  def play(:signout, _loopdata) do
    MusicService.signout
    {:next_state, :signin, []}
  end
end
