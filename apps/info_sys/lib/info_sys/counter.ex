defmodule InfoSys.Counter do
  #Client side
  def inc(pid), do: send(pid, :inc)

  def dec(pid), do: send(pid, :dec)

  def val(pid, timeout \\ 5000) do
    ref = make_ref()
    send(pid, {:value, self(), ref})

    receive do
      {^ref, value} -> value
    after
      timeout -> exit(:timeout)
    end
  end

  #Server side
  def start_link(initial_value) do
    {:ok, spawn_link(fn -> listen(initial_value) end)}
  end

  defp listen(value) do
    receive do
      :inc -> listen(value + 1)
      :dec -> listen(value - 1)
      {:value, sender, ref} ->
        send(sender, {ref, value})
        listen(value)
    end

  end
end
