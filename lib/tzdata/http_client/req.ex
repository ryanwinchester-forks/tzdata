if Code.ensure_loaded?(Req) do
  defmodule Tzdata.HTTPClient.Req do
    @moduledoc false

    @behaviour Tzdata.HTTPClient

    @impl true
    def get(url, headers, options) do
      case Req.get(url, req_options(headers, options)) do
        {:ok, %Req.Response{status: status, headers: resp_headers, body: body}} ->
          {:ok, {status, normalize_headers(resp_headers), body}}

        {:error, reason} ->
          {:error, reason}
      end
    end

    @impl true
    def head(url, headers, options) do
      case Req.head(url, req_options(headers, options)) do
        {:ok, %Req.Response{status: status, headers: resp_headers}} ->
          {:ok, {status, normalize_headers(resp_headers)}}

        {:error, reason} ->
          {:error, reason}
      end
    end

    defp req_options(headers, options) do
      [
        headers: headers,
        redirect: Keyword.get(options, :follow_redirect, false),
        # The downloaded tar.gz must be returned as-is, so disable Req's
        # automatic decompression and body decoding.
        raw: true
      ]
    end

    # Req (v0.4+) return headers as a map of lists.
    defp normalize_headers(headers) when is_map(headers) do
      for {name, values} <- headers, value <- values, do: {name, value}
    end
  end
end
