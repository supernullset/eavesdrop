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
  def start_link(service \\ MusicService) do
    :gen_fsm.start_link({:local, __MODULE__}, __MODULE__, [service], [])
  end

  @doc "
  Puts the FSM in its initial state and traps exits for loud errors

  service is a callback module responsible for handling actual calls
  and changes on a theoretical server
  "
  def init([service]) do
    Process.flag(:trap_exit, true)
    {:ok, :signin, [service]}
  end

  @doc "Defines a handler for receiving messages while in the _signin_ state"
  def signin({:signin, name}, [service] = loopdata) do
    apply(service, :signin, [name])

    {:next_state, :play, loopdata}
  end
  def signin(_any, loopdata) do
    {:next_state, :signin, loopdata}
  end

  @doc "Defines a handler for receiving messages while in the _idle_ state"
  def idle(:idle, loopdata) do
    {:next_state, :play, loopdata}
  end
  def idle({:play, track}, [service] = loopdata) do
    apply(service, :play, [track])

    {:next_state, :play, loopdata}
  end
  def idle(:signout, [service] = loopdata) do
    apply(service, :signout, [])

    {:next_state, :signin, loopdata}
  end

  @doc "Defines messages for receiving messages while on the _play_ state"
  def play({:play, track}, [service] = loopdata) do
    apply(service, :play, [track])

    {:next_state, :play, loopdata}
  end
  def play(:stop, [service] = loopdata) do
    apply(service, :idle, [])

    {:next_state, :idle, loopdata}
  end
  def play(:signout, [service] = loopdata) do
    apply(service, :signout, [])

    {:next_state, :signin, loopdata}
  end
end
