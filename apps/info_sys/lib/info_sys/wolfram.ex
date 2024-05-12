defmodule InfoSys.Wolfram do
  import SweetXml
  alias InfoSys.Result

  #We are implementing the InfoSys.Backend behaviour defined on the backend.ex file
  @behaviour InfoSys.Backend

  @base "http://api.wolframalpha.com/v2/query"

  #@impl true --> Means this is the implementation of the behaviour we set before. This happens for the finction name & compute
  @impl true
  def name, do: "wolfram"

  @impl true
  def compute(query_str, _opts) do
    query_str
    |> fetch_xml()
    |> xpath(~x"/queryresult/pod[contains(@title, 'Result') or
                                 contains(@title, 'Definitions')]
                            /subpod/plaintext/text()")
    |> build_result()
  end

  defp build_result(nil), do: []
  defp build_result(answer) do
    [%Result{backend: __MODULE__, score: 95, text: to_string(answer)}]
  end

  @http Application.compile_env(:info_sys, :wolfram)[:http_client] || :httpc
  defp fetch_xml(query) do
    {:ok, {_, _, body}} = @http.request(String.to_charlist(url(query)))

    body
  end

  defp url(input) do
    "#{@base}?" <> URI.encode_query(appid: id(), input: input, format: "plaintext")
  end

  defp id, do: Application.fetch_env!(:info_sys, :wolfram)[:app_id]
end
