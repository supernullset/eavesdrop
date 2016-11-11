defmodule EavesdropOTP.UserSession do
  @moduledoc "A module which represents the current actions of a user
  on the system. The FSM can be in 1 of 3 states at any given time:
  signin, idle, or play. This module defines the actions which take
  each state to the others"

  @music_service Application.get_env(:eavesdrop_otp, :music_service)
  @behaviour :gen_statem

  defmodule UserState do
    defstruct user_name: nil, current_track: nil, last_message: "Idle"
  end

  @doc "Kicks off a user process"
  def start_link(user_name) do
    :gen_statem.start_link(
      via_tuple(user_name), # NameScope
      __MODULE__, # Module
      user_name,  # arguments to pass to init
      []
    )
  end

  @doc "
  Puts the FSM in its initial state

  service is a callback module responsible for handling actual calls
  and changes on a theoretical server
  "
  def init(user_name) do
    @music_service.signin(user_name)

    {:ok, :idle, %UserState{user_name: user_name}}
  end

  def callback_mode, do: :state_functions

  @doc "shutdown callback for the user"
  def terminate(reason, _state_name, %UserState{user_name: user_name} = state) do
    @music_service.shutdown(user_name, reason)
  end

  @doc "required function for hot upgrades"
  def code_change(_vsn, state, data, _extra) do
    {:ok, state, data}
  end


  #External functions

  @doc "Play a track for a user"
  def play_track(user_name, track) do
    via = via_tuple(user_name)

    :gen_statem.call(via, {:play, track})
  end

  @doc "Stop a track for a user"
  def stop_track(user_name) do
    via = via_tuple(user_name)

    :gen_statem.call(via, :stop)
  end

  @doc "Signin user"
  def signin(user_name) do
    EavesdropOTP.Supervisor.start_child(user_name)
  end

  @doc "Signout user"
  def signout(user_name) do
    # This is arguably too raw. Rather than terminating at the top, I
    # would prefer to be able to gracefully shut down from within this
    # module and have it "bubble up"
    EavesdropOTP.Supervisor.terminate_child(user_name)
  end

  @doc "Determine if a user is registered in the system"
  def present?(user_name) do
    case :gproc.where(gproc_key(user_name)) do
      pid when is_pid(pid) -> true
      :undefined -> false
      _ -> false
    end
  end

  @doc "Get the last message for user"
  def last_message(user_name) do
    %UserState{
      last_message: last_message,
      current_track: _,
      user_name: _
    } = status(user_name)

    last_message
  end

  @doc "Get the current track name for a user"
  def current_track(user_name) do
    %UserState{
      current_track: current_track,
      last_message: _,
      current_track: _
    } = status(user_name)

    current_track
  end

  @doc "utility function to get the current state held in the statem process"
  defp status(user_name) do
    via = via_tuple(user_name)

    {:ok, state} = :gen_statem.call(via, :status)

    state
  end

  @doc "utility function to return actual pid of process"
  defp get_pid(user_name) do
    user_name
    |> gproc_key
    |> :gproc.where
  end

  @doc "utility function to lookup a process in gproc"
  defp via_tuple(user_name) do
    {:via, :gproc, gproc_key(user_name)}
  end

  @doc "The gproc key"
  defp gproc_key(user_name) do
    {:n, :l, "#{user_name}_session"}
  end

  # FSM Server functions
  @doc "Defines a handler for receiving messages while in the _idle_ state"
  def idle({:call, from}, :idle, %UserState{user_name: user_name} = state) do
    {
      :next_state,
      :play,
      state,
      [
        {:reply, from, :play}
      ]
    }
  end
  def idle({:call, from}, {:play, track}, %UserState{user_name: user_name} = state) do
    {:ok, message} = @music_service.play(user_name, track)

    {
      :next_state,
      :play,
      %UserState{ state | last_message: message, current_track: track},
      [
        {:reply, from, {:ok, message}}
      ]
    }
  end
  def idle({:call, from}, :status, state) do
    {
      :keep_state,
      state,
      [
        {:reply, from, {:ok, state}}
      ]
    }
  end
  def idle(_any, from, %UserState{user_name: user_name} = state) do
    {:ok, message} = @music_service.idle(user_name)

    {
      :keep_state,
      state, [
        {:reply, from, {:ok, message}}
      ]
    }
  end

  @doc "Defines messages for receiving messages while on the _play_ state"
  def play({:call, from}, {:play, track}, %UserState{user_name: user_name} = state) do
    {:ok, message} = @music_service.play(user_name, track)

    {
      :next_state,
      :play,
      %UserState{ state | last_message: message, current_track: track},
      [
        {:reply, from, {:ok, message}}
      ]
    }
  end
  def play({:call, from}, :stop, %UserState{user_name: user_name} = state) do
    {:ok, message} = @music_service.idle(user_name)

    {
      :next_state,
      :idle,
      %UserState{ state | last_message: message, current_track: nil},
      [
        {:reply, from, {:ok, message}}
      ]
    }
  end
  def play({:call, from}, :status, state) do
    {
      :keep_state,
      state,
      [
        {:reply, from, {:ok, state}}
      ]
    }
  end
  def play(_any, from, %UserState{user_name: user_name} = state) do
    {:ok, message} = @music_service.idle(user_name)

    {
      :keep_state,
      %UserState{ state | last_message: message, current_track: nil},
      [
        {:reply, from, {:ok, message}}
      ]
    }
  end
end
