defmodule Ecto.ULID do
  @moduledoc """
  An Ecto type for ULID strings.
  """

  alias Ecto.ULID.{Encoder, Decoder}

  @crockford_alphabet "0123456789ABCDEFGHJKMNPQRSTVWXYZ"

  # replace with `use Ecto.Type` after Ecto 3.2.0 is required
  @behaviour Ecto.Type
  # and remove both of these functions
  def embed_as(_), do: :self
  def equal?(term1, term2), do: term1 == term2

  @typedoc """
  An Crockford 32 encoded ULID string
  """
  @type t :: <<_::208>>

  @typedoc """
  A raw binary representation of a ULID
  """
  @type raw :: <<_::128>>

  @typedoc """
  A UUID representation of a ULID
  """
  @type uuid :: <<_::288>>

  @doc """
  The underlying schema type.
  """
  def type, do: :uuid

  @spec crockford_alphabet() :: String.t()
  def crockford_alphabet, do: @crockford_alphabet

  @doc """
  Casts a string (including a UUID hex string) to ULID.
  """
  def cast(<<_::bytes-size(26)>> = value) do
    if valid?(value) do
      {:ok, value}
    else
      :error
    end
  end

  def cast(<<_::bytes-size(36)>> = value) do
    with {:ok, hex_uuid} <- Ecto.UUID.cast(value),
         {:ok, decoded} <- dump(hex_uuid),
         {:ok, ulid} <- load(decoded) do
      {:ok, ulid}
    else
      :error -> :error
    end
  end

  def cast(_), do: :error

  @doc """
  Same as `cast/1` but raises `Ecto.CastError` on invalid arguments.
  """
  def cast!(value) do
    case cast(value) do
      {:ok, ulid} -> ulid
      :error -> raise Ecto.CastError, type: __MODULE__, value: value
    end
  end

  @doc """
  Converts a Crockford Base32 or UUID hex encoded ULID  into a binary.
  """
  def dump(<<_::bytes-size(26)>> = encoded), do: Decoder.decode(encoded)
  defdelegate dump(encoded), to: Ecto.UUID

  @doc """
  Converts a binary ULID into a Crockford Base32 encoded string.
  """
  def load(<<_::unsigned-size(128)>> = bytes), do: Encoder.encode(bytes)
  def load(_), do: :error

  @doc false
  def autogenerate, do: generate()

  @doc """
  Generates a Crockford Base32 encoded ULID.

  If a value is provided for `timestamp`, the generated ULID will be for the provided timestamp.
  Otherwise, a ULID will be generated for the current time.

  Arguments:

  * `timestamp`: A Unix timestamp with millisecond precision.
  """
  def generate(timestamp \\ System.system_time(:millisecond)) do
    {:ok, ulid} = Encoder.encode(bingenerate(timestamp))
    ulid
  end

  @doc """
  Generates a binary ULID.

  If a value is provided for `timestamp`, the generated ULID will be for the provided timestamp.
  Otherwise, a ULID will be generated for the current time.

  Arguments:

  * `timestamp`: A Unix timestamp with millisecond precision.
  """
  def bingenerate(timestamp \\ System.system_time(:millisecond)) do
    <<timestamp::unsigned-size(48), :crypto.strong_rand_bytes(10)::binary>>
  end

  # credo:disable-for-next-line
  defp valid?(
         <<c1::8, c2::8, c3::8, c4::8, c5::8, c6::8, c7::8, c8::8, c9::8, c10::8, c11::8, c12::8,
           c13::8, c14::8, c15::8, c16::8, c17::8, c18::8, c19::8, c20::8, c21::8, c22::8, c23::8,
           c24::8, c25::8, c26::8>>
       ) do
    v(c1) && v(c2) && v(c3) && v(c4) && v(c5) && v(c6) && v(c7) && v(c8) && v(c9) && v(c10) &&
      v(c11) && v(c12) && v(c13) &&
      v(c14) && v(c15) && v(c16) && v(c17) && v(c18) && v(c19) && v(c20) && v(c21) && v(c22) &&
      v(c23) && v(c24) && v(c25) && v(c26)
  end

  defp valid?(_), do: false

  @compile {:inline, v: 1}

  defp v(?0), do: true
  defp v(?1), do: true
  defp v(?2), do: true
  defp v(?3), do: true
  defp v(?4), do: true
  defp v(?5), do: true
  defp v(?6), do: true
  defp v(?7), do: true
  defp v(?8), do: true
  defp v(?9), do: true
  defp v(?A), do: true
  defp v(?B), do: true
  defp v(?C), do: true
  defp v(?D), do: true
  defp v(?E), do: true
  defp v(?F), do: true
  defp v(?G), do: true
  defp v(?H), do: true
  defp v(?J), do: true
  defp v(?K), do: true
  defp v(?M), do: true
  defp v(?N), do: true
  defp v(?P), do: true
  defp v(?Q), do: true
  defp v(?R), do: true
  defp v(?S), do: true
  defp v(?T), do: true
  defp v(?V), do: true
  defp v(?W), do: true
  defp v(?X), do: true
  defp v(?Y), do: true
  defp v(?Z), do: true
  defp v(_), do: false
end
