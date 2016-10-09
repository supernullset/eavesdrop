defmodule MusicService do
  @name "Rdio"
  use GenEvent

  def handle_event({:signin, user}, parent) do
    IO.puts "Hi #{user}, welcome back"

    {:ok, parent}
  end

  def handle_event({:play, trackname}, parent) do
    IO.puts "You are now listening to #{trackname} on #{@name}"

    {:ok, parent}
  end

  def handle_event(:idle, parent) do
    IO.puts "Idle"

    {:ok, parent}
  end

  def handle_event(:signout, parent) do
    IO.puts "See you next time"

    {:ok, parent}
  end
end
