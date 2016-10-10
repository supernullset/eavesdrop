defmodule MusicService do
  @name "Rdio"
  use GenServer

  def start_link(user_name) do
    GenServer.start_link(__MODULE__, user_name,
      name: whereis(user_name)
    )
  end

  def init(user_name) do
    {:ok, user_name}
  end

  # interface functions
  def play(user, trackname) do
    GenServer.call(whereis(user), {:play, trackname})
  end

  def idle(user) do
    GenServer.call(whereis(user), :idle)
  end

  def signin(user) do
    GenServer.call(whereis(user), :signin)
  end

  def signout(user) do
    GenServer.call(whereis(user), :signout)
  end

  def shutdown(user, reason) do
    GenServer.call(whereis(user), {:shutdown, reason})
  end


  # internal functions
  def whereis(user_name) do
    {:via, :gproc, {:n, :l, {:music_service, user_name}}}
  end

  def handle_call({:play, trackname}, _from, user_name) do
    IO.puts "You are now listening to #{trackname} on #{@name}"

    {:reply, :ok, user_name}
  end

  def handle_call(:idle, _from, user_name) do
    IO.puts "Idle"

    {:reply, :ok, user_name}
  end

  def handle_call(:signin, _from, user_name) do
    IO.puts "Welcome back to #{@name} #{user_name}"

    {:reply, :ok, user_name}
  end

  def handle_call(:signout, _from, user_name) do
    IO.puts "See you next time"

    {:reply, :ok, user_name}
  end

  def handle_call({:shutdown, reason}, _from, user_name) do
    IO.puts "Service is going down..."
    IO.puts inspect(reason)

    # TODO: handle cleanup?

    {:reply, :ok, user_name}
  end
end
