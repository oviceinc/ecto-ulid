defmodule Ecto.ULID.Decoder do
  @moduledoc """
  Decoder for handling ULIDs
  """

  alias Ecto.ULID

  @crockford_alphabet "0123456789ABCDEFGHJKMNPQRSTVWXYZ"

  @spec decode(ULID.t()) :: {:ok, ULID.raw()} | :error
  def decode(<<_::unsigned-size(208)>> = text) do
    decode_bytes(text, <<>>)
  catch
    :error -> :error
  else
    bin -> {:ok, bin}
  end

  def decode(_), do: :error

  defp decode_bytes(<<>>, <<_::2, shifted::bitstring>>), do: shifted

  defp decode_bytes(<<codepoint::unsigned, rest::bitstring>>, acc) do
    decode_bytes(rest, <<acc::bitstring, i(codepoint)::unsigned-size(5)>>)
  end

  @compile {:inline, i: 1}

  for n <- 0..31 do
    defp i(unquote(:binary.at(@crockford_alphabet, n))), do: unquote(n)
  end

  defp i(_), do: throw(:error)

  @compile {:inline, d: 1}

  defp d(?0), do: 0
  defp d(?1), do: 1
  defp d(?2), do: 2
  defp d(?3), do: 3
  defp d(?4), do: 4
  defp d(?5), do: 5
  defp d(?6), do: 6
  defp d(?7), do: 7
  defp d(?8), do: 8
  defp d(?9), do: 9
  defp d(?A), do: 10
  defp d(?B), do: 11
  defp d(?C), do: 12
  defp d(?D), do: 13
  defp d(?E), do: 14
  defp d(?F), do: 15
  defp d(?a), do: 10
  defp d(?b), do: 11
  defp d(?c), do: 12
  defp d(?d), do: 13
  defp d(?e), do: 14
  defp d(?f), do: 15
  defp d(_), do: throw(:error)
end
