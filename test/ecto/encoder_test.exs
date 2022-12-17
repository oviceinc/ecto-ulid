defmodule Ecto.ULID.EncoderTest do
  use ExUnit.Case, async: true

  alias Ecto.ULID.Encoder

  @raw <<1, 95, 194, 60, 108, 73, 209, 114, 136, 236, 133, 115, 106, 195, 145, 22>>
  @encoded "01BZ13RV29T5S8HV45EDNC748P"
  @encoded_uuid "015fc23c-6c49-d172-88ec-85736ac39116"

  describe "encode/1" do
    test "encodes a raw ULID to Crockford representation" do
      assert {:ok, ulid} = Encoder.encode(@raw)
      assert String.length(ulid) == 26
      assert ulid == @encoded
    end
  end

  describe "encode_uuid/1" do
    test "encodes a raw ULID to UUID representation" do
      assert {:ok, ulid} = Encoder.encode_uuid(@raw)
      assert String.length(ulid) == 36
      assert ulid == @encoded_uuid
    end
  end
end
