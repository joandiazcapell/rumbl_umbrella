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
    Process.send_after(self(), :tick, 1000)
    {:ok, initial_value}
  end

  def handle_info(:tick, value) when value <= 0, do: raise "boom!"

  def handle_info(:tick, value) do
    IO.puts("tick #{value}")
    Process.send_after(self(), :tick, 1000)
    {:noreply, value - 1}
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
