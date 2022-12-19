defmodule Ecto.ULID.DecoderTest do
  use ExUnit.Case, async: true

  alias Ecto.ULID.Decoder

  @raw <<1, 95, 194, 60, 108, 73, 209, 114, 136, 236, 133, 115, 106, 195, 145, 22>>
  @encoded "01BZ13RV29T5S8HV45EDNC748P"
  @encoded_uuid "015fc23c-6c49-d172-88ec-85736ac39116"

  describe "decode/1" do
    test "decodes a Crockford string to raw ULID binary" do
      assert {:ok, raw} = Decoder.decode(@encoded)
      assert byte_size(raw) == 16
      assert raw == @raw
    end
  end

  describe "decode_uuid/1" do
    test "decodes a UUID encoded string to raw ULID binary" do
      assert {:ok, raw} = Decoder.decode_uuid(@encoded_uuid)
      assert byte_size(raw) == 16
      assert raw == @raw
    end
  end
end
