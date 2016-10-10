defmodule EavesdropOTP.Worker do
  @moduledoc "A module which represents the current actions of a user
  on the system. The FSM can be in 1 of 3 states at any given time:
  signin, idle, or play. This module defines the actions which take
  each state to the others"

  @doc "Kicks off a user process"
  def start_link(user_name) do
    :gen_fsm.start_link(via(user_name), __MODULE__, [user_name], [])
  end

  #External functions

  @doc "External interaction functions"
  def play_track(user_name, track) do
    :gen_fsm.send_event(via(user_name), {:play, track})
  end
  def stop_track(user_name) do
    :gen_fsm.send_event(via(user_name), :stop)
  end
  def signout(user_name) do
    :gen_fsm.stop(via(user_name))
  end

  def via(id) do
    {:via, :gproc, {:n, :l, {__MODULE__, id}}}
  end

  def via_manager(name) do
    {:via, :gproc, {:n, :l, {GenEvent, name}}}
  end

  # FSM Server functions

  @doc "
  Puts the FSM in its initial state and traps exits for loud errors

  service is a callback module responsible for handling actual calls
  and changes on a theoretical server
  "
  def init(user_name) do
    GenEvent.add_handler(via_manager(user_name), MusicService, self())

    Process.flag(:trap_exit, true)
    GenEvent.notify(via_manager(user_name), {:signin, user_name})

    {:ok, :play, user_name}
  end

  @doc "Defines a handler for receiving messages while in the _idle_ state"
  def idle(:idle, user_name) do
    {:next_state, :play, user_name}
  end
  def idle({:play, track}, user_name) do
    GenEvent.notify(via_manager(user_name), {:play, track})

    {:next_state, :play, user_name}
  end
  def idle(_any, user_name) do
    GenEvent.notify(via_manager(user_name), :idle)
    {:next_state, :idle, user_name}
  end

  @doc "Defines messages for receiving messages while on the _play_ state"
  def play({:play, track}, user_name) do
    GenEvent.notify(via_manager(user_name), {:play, track})

    {:next_state, :play, user_name}
  end
  def play(:stop, user_name) do
    GenEvent.notify(via_manager(user_name), :idle)

    {:next_state, :idle, user_name}
  end
  def play(_any, user_name) do
    GenEvent.notify(via_manager(user_name), :idle)

    {:next_state, :idle, user_name}
  end

  def terminate(reason, _state_name, user_name) do
    GenEvent.notify(via_manager(user_name), {:shutdown, reason})
  end
end
