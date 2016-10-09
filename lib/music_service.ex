defmodule MusicService do
  @name "Rdio"

  def signin(user) do
    IO.puts "Hi #{user}, welcome back"
  end

  def play(trackname) do
    IO.puts "You are now listening to #{trackname} on #{@name}"
  end

  def idle do
    IO.puts "Idle"
  end

  def signout do
    IO.puts "See you next time"
  end
end
