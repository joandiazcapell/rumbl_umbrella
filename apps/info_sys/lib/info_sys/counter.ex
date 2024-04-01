defmodule InfoSys.Counter do
  use GenServer
  #Client side
  def inc(pid), do: GenServer.cast(pid, :inc)

  def dec(pid), do: GenServer.cast(pid, :dec)

  def val(pid) do
    GenServer.call(pid, :val)
  end

  #Server side
  def start_link(initial_value) do
    GenServer.start_link(__MODULE__, initial_value)
  end

  def init(initial_value) do
    {:ok, initial_value}
  end

  def handle_cast(:inc, value) do
    {:noreply, value + 1}
  end

  def handle_cast(:dec, value) do
    {:noreply, value - 1}
  end

  def handle_call(:val, _from, value) do
    {:reply, value, value}
  end
end
