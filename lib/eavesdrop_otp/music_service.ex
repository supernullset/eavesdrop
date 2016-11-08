defmodule EavesdropOTP.MusicService do
  @name "Rdio"
  use GenServer

  def start_link(user_name) do
    GenServer.start_link(__MODULE__, user_name,
      name: via_tuple(user_name)
    )
  end

  def init(user_name) do
    {:ok, user_name}
  end

  # interface functions
  def play(user, trackname) do
    GenServer.call(via_tuple(user), {:play, trackname})
  end

  def idle(user) do
    GenServer.call(via_tuple(user), :idle)
  end

  def signin(user) do
    GenServer.call(via_tuple(user), :signin)
  end

  def signout(user) do
    GenServer.call(via_tuple(user), :signout)
  end

  def shutdown(user, reason) do
    GenServer.call(via_tuple(user), {:shutdown, reason})
  end


  # internal functions
  def via_tuple(user_name) do
    {:via, :gproc, {:n, :l, "#{user_name}_music_service"}}
  end

  def handle_call({:play, trackname}, _from, user_name) do
    message = "You are now listening to #{trackname} on #{@name}"
    {:reply, {:ok, message}, user_name}
  end

  def handle_call(:idle, _from, user_name) do
    message = "Idle"

    {:reply, {:ok, message}, user_name}
  end

  def handle_call(:signin, _from, user_name) do
    message =  "Welcome back to #{@name} #{user_name}"

    {:reply, {:ok, message}, user_name}
  end

  def handle_call(:signout, _from, user_name) do
    message = "See you next time"

    {:reply, {:ok, message}, user_name}
  end

  def handle_call({:shutdown, reason}, _from, user_name) do
    message = "Service is going down..."
    reason  = inspect(reason)

    # TODO: handle cleanup?

    {:reply, {:ok, message, reason}, user_name}
  end
end
