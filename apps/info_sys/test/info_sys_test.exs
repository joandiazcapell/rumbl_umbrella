defmodule InfoSysTest do
  use ExUnit.Case
  alias InfoSys.Result

  doctest InfoSys
@moduledoc """
We define a stub as a Backend here to be able to test InfoSys
Stubs vs Mock
  - Stub: Replace real-world libraries with simpler, predictavle behaviour. Therefore we can bypass code that would be hard to test.
  - Mock: Similar to Stubs but greater role. It replaces real-world behaviours just as a stub does, but it does so by allowing programmers to specify expectations and results.
          A mock will fail a test if the test code doesn't receive the expected function calls.
"""
  defmodule TestBackend do
    def name(), do: "Wolfram"

    def compute("result", _opts), do: [%Result{backend: __MODULE__, text: "result"}]
    def compute("none", _opts), do: []
    def compute("timeout", _opts), do: Process.sleep(:infinity)
    def compute("boom", _opts), do: raise "boom!"

  end

  test "compute/2 with backend results" do
    assert [%Result{backend: TestBackend, text: "result"}] = InfoSys.compute("result", backends: [TestBackend])
  end

  test "compute/2 with no backend results" do
    assert [] = InfoSys.compute("none", backends: [TestBackend])
  end

  test "compute/2 with timeout returns no results" do
    results = InfoSys.compute("timeout", backends: [TestBackend], timeout: 10)
    assert results == []
  end

  #We capture the log in a test tag so it is clean
  @tag :capture_log
  test "compute/2 discard backend errors" do
    assert InfoSys.compute("boom", backends: [TestBackend]) == []
  end
end
