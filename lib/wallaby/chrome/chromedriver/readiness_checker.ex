defmodule Wallaby.Chrome.Chromedriver.ReadinessChecker do
  @moduledoc false

  @type url :: String.t()

  @spec wait_until_ready(url, non_neg_integer()) :: :ok
  def wait_until_ready(base_url, delay \\ 200)
      when is_binary(base_url) and is_integer(delay) and delay >= 0 do
    if ready?(base_url) do
      :ok
    else
      Process.sleep(delay)
      wait_until_ready(base_url, delay)
    end
  end

  @spec ready?(url) :: boolean
  defp ready?(base_url) do
    status_url = String.trim_trailing(base_url, "/") <> "/status"

    case :httpc.request(:get, {to_charlist(status_url), []}, [autoredirect: false], body_format: :binary) do
      {:ok, {{_, 200, _}, _headers, body}} ->
        case Jason.decode(body) do
          {:ok, %{"value" => %{"ready" => true}}} -> true
          _ -> false
        end

      _ ->
        false
    end
  end
end
