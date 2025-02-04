defmodule Ecto.ULID.Encoder do
  @moduledoc """
  Encoder for handling raw ULIDs
  """

  alias Ecto.ULID

  @ulid_raw_bit_size 128

  @doc """
  Encodes a Ulid binary to its textual form.

  ## Examples
      iex> ulid = Ecto.ULID.bingenerate()
      <<1, 133, 30, 8, 155, 215, 184, 43, 56, 111, 3, 250, 159, 236, 243, 192>>
      iex> Ecto.ULID.Encoder.encode(ulid)
      {:ok, "01GMF0H6YQQ0NKGVR3ZAFYSWY0"}
  """
  @spec encode(ULID.raw()) :: {:ok, ULID.t()} | :error
  def encode(<<_::unsigned-size(@ulid_raw_bit_size)>> = bytes) do
    encode_bytes(<<0::2, bytes::binary>>, <<>>)
  catch
    _ -> :error
  else
    encoded -> {:ok, encoded}
  end

  def encode(_), do: :error

  @spec encode_uuid(ULID.raw()) :: {:ok, ULID.uuid()} | :error
  def encode_uuid(
        <<a1::4, a2::4, a3::4, a4::4, a5::4, a6::4, a7::4, a8::4, b1::4, b2::4, b3::4, b4::4,
          c1::4, c2::4, c3::4, c4::4, d1::4, d2::4, d3::4, d4::4, e1::4, e2::4, e3::4, e4::4,
          e5::4, e6::4, e7::4, e8::4, e9::4, e10::4, e11::4, e12::4>>
      ) do
    <<e(a1), e(a2), e(a3), e(a4), e(a5), e(a6), e(a7), e(a8), ?-, e(b1), e(b2), e(b3), e(b4), ?-,
      e(c1), e(c2), e(c3), e(c4), ?-, e(d1), e(d2), e(d3), e(d4), ?-, e(e1), e(e2), e(e3), e(e4),
      e(e5), e(e6), e(e7), e(e8), e(e9), e(e10), e(e11), e(e12)>>
  catch
    _ -> :error
  else
    encoded -> {:ok, encoded}
  end

  for n <- 0..31 do
    defp encode_bytes(<<unquote(n)::unsigned-size(5), rest::bitstring>>, acc) do
      encode_bytes(rest, acc <> unquote(String.at(ULID.crockford_alphabet(), n)))
    end
  end

  defp encode_bytes(<<>>, acc), do: acc

  @compile {:inline, e: 1}

  defp e(0), do: ?0
  defp e(1), do: ?1
  defp e(2), do: ?2
  defp e(3), do: ?3
  defp e(4), do: ?4
  defp e(5), do: ?5
  defp e(6), do: ?6
  defp e(7), do: ?7
  defp e(8), do: ?8
  defp e(9), do: ?9
  defp e(10), do: ?a
  defp e(11), do: ?b
  defp e(12), do: ?c
  defp e(13), do: ?d
  defp e(14), do: ?e
  defp e(15), do: ?f
  defp e(_), do: :error
end
