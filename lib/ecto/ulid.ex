defmodule Ecto.ULID do
  @moduledoc """
  An Ecto type for ULID strings.
  """

  use Ecto.Type

  alias Ecto.ULID.{Encoder, Decoder}

  @crockford_alphabet "0123456789ABCDEFGHJKMNPQRSTVWXYZ"
  @ulid_bit_size 208
  @ulid_raw_bit_size 128
  @uuid_bit_size 288

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
  @spec cast(binary() | uuid()) :: {:ok, t()} | :error
  def cast(<<_::unsigned-size(@ulid_bit_size)>> = value) do
    if valid?(value) do
      {:ok, value}
    else
      :error
    end
  end

  def cast(<<_::unsigned-size(@uuid_bit_size)>> = value) do
    case Ecto.UUID.cast(value) do
      {:ok, uuid} -> {:ok, from_uuid(uuid)}
      :error -> :error
    end
  end

  def cast(_), do: :error

  @doc """
  Same as `cast/1` but raises `Ecto.CastError` on invalid arguments.
  """
  @spec cast!(binary() | uuid()) :: t()
  def cast!(value) do
    case cast(value) do
      {:ok, ulid} -> ulid
      :error -> raise Ecto.CastError, type: __MODULE__, value: value
    end
  end

  @doc """
  Converts a Crockford Base32 or UUID hex encoded ULID  into a binary.
  """
  @spec dump(t() | uuid()) :: {:ok, raw()} | :error
  def dump(<<_::unsigned-size(@ulid_bit_size)>> = encoded), do: Decoder.decode(encoded)
  defdelegate dump(encoded), to: Ecto.UUID

  @doc """
  Converts a binary ULID into a Crockford Base32 encoded string.
  """
  @spec load(raw()) :: {:ok, t()} | :error
  def load(<<_::unsigned-size(@ulid_raw_bit_size)>> = bytes), do: Encoder.encode(bytes)
  def load(_), do: :error

  @doc false
  @spec autogenerate :: t()
  def autogenerate, do: uuid_generate()

  @doc """
  Generates a Crockford Base32 encoded ULID.

  If a value is provided for `timestamp`, the generated ULID will be for the provided timestamp.
  Otherwise, a ULID will be generated for the current time.

  Arguments:

  * `timestamp`: A Unix timestamp with millisecond precision.
  """
  @spec generate(none() | integer()) :: t()
  def generate(timestamp \\ System.system_time(:millisecond)) do
    {:ok, ulid} = timestamp |> bingenerate() |> Encoder.encode()
    ulid
  end

  @doc """
  Generates a binary ULID.

  If a value is provided for `timestamp`, the generated ULID will be for the provided timestamp.
  Otherwise, a ULID will be generated for the current time.

  Arguments:

  * `timestamp`: A Unix timestamp with millisecond precision.
  """
  @spec bingenerate(none() | integer()) :: raw()
  def bingenerate(timestamp \\ System.system_time(:millisecond)) do
    <<timestamp::unsigned-size(48), :crypto.strong_rand_bytes(10)::binary>>
  end

  @spec uuid_generate(none() | integer()) :: uuid()
  def uuid_generate(timestamp \\ System.system_time(:millisecond)) do
    {:ok, uuid} = timestamp |> bingenerate() |> Encoder.encode_uuid()
    uuid
  end

  @doc """
  Extracts the timestamp from a ULID
  """
  @spec extract_timestamp(raw() | t() | uuid()) :: integer() | :error
  def extract_timestamp(<<_::unsigned-size(@ulid_bit_size)>> = text) do
    with {:ok, bytes} <- Decoder.decode(text), do: extract_timestamp(bytes)
  end

  def extract_timestamp(<<_::unsigned-size(@uuid_bit_size)>> = text) do
    with {:ok, bytes} <- Decoder.decode_uuid(text), do: extract_timestamp(bytes)
  end

  def extract_timestamp(<<timestamp::unsigned-size(48), _rest::unsigned-size(80)>>),
    do: timestamp

  @doc """
  Convert a ULID to its UUID form
  """
  @spec to_uuid(t() | raw()) :: uuid() | :error
  def to_uuid(<<_::unsigned-size(@ulid_bit_size)>> = text) do
    with {:ok, bytes} <- Decoder.decode(text), do: to_uuid(bytes)
  end

  def to_uuid(<<_::unsigned-size(@ulid_raw_bit_size)>> = text) do
    with {:ok, uuid} <- Encoder.encode_uuid(text), do: uuid
  end

  @doc """
  Convert a ULID from its UUID from
  """
  @spec from_uuid(uuid()) :: t() | :error
  def from_uuid(<<_::unsigned-size(@uuid_bit_size)>> = text) do
    with {:ok, bytes} <- Decoder.decode_uuid(text),
         {:ok, ulid} <- Encoder.encode(bytes) do
      ulid
    end
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

  for n <- 0..31 do
    defp v(unquote(:binary.at(@crockford_alphabet, n))), do: true
  end

  defp v(_), do: false
end
