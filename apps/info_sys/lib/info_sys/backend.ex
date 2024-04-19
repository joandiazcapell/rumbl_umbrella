defmodule InfoSys.Backend do
  @moduledoc """
  We defined two callbacks (name & compute) for the backend as a tinny contract between the information system and each backend.
  We define two functions. We don't actually declare a function. Instead, we use typespecs, which specify not just the name of our function but also the types of arguments and return values
  """
  @callback name() :: String.t()
  @callback compute(query :: String.t(), opts :: Keyword.t()) :: [%InfoSys.Result{}]
end
