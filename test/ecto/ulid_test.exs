defmodule Ecto.ULIDTest do
  use ExUnit.Case, async: true

  @binary <<1, 95, 194, 60, 108, 73, 209, 114, 136, 236, 133, 115, 106, 195, 145, 22>>
  @encoded "01BZ13RV29T5S8HV45EDNC748P"
  @encoded_uuid "015fc23c-6c49-d172-88ec-85736ac39116"

  @timestamp 1_469_918_176_385

  describe "generate/0" do
    test "encodes milliseconds in first 10 characters" do
      # test case from ULID README: https://github.com/ulid/javascript#seed-time
      assert <<encoded::bytes-size(10), _rest::bytes-size(16)>> = Ecto.ULID.generate(@timestamp)
      assert encoded == "01ARYZ6S41"
    end

    test "generates unique identifiers" do
      ulid1 = Ecto.ULID.generate()
      ulid2 = Ecto.ULID.generate()

      assert ulid1 != ulid2
    end

    test "should be sortable" do
      ulid1 = Ecto.ULID.generate()
      Process.sleep(1)
      ulid2 = Ecto.ULID.generate()

      assert ulid2 > ulid1
    end
  end

  describe "bingenerate/0" do
    test "encodes milliseconds in first 48 bits" do
      now = System.system_time(:millisecond)
      assert <<time::48, _random::80>> = Ecto.ULID.bingenerate()
      assert_in_delta now, time, 10
    end

    test "generates unique identifiers" do
      ulid1 = Ecto.ULID.bingenerate()
      ulid2 = Ecto.ULID.bingenerate()

      assert ulid1 != ulid2
    end
  end

  describe "uuid_generate/0" do
    test "generates unique identifiers" do
      uuid1 = Ecto.ULID.uuid_generate()
      uuid2 = Ecto.ULID.uuid_generate()

      assert uuid1 != uuid2
    end

    test "should be sortable" do
      uuid1 = Ecto.ULID.uuid_generate()
      Process.sleep(1)
      uuid2 = Ecto.ULID.uuid_generate()

      assert uuid2 > uuid1
    end
  end

  describe "extract_timestamp/1" do
    test "extracts a timestamp from a text ulid" do
      ulid = "01ARYZ6S4124TJP2BQQZX06FKM"
      assert Ecto.ULID.extract_timestamp(ulid) == @timestamp
    end

    test "extracts a timestamp from a raw ulid" do
      ulid = <<1, 86, 61, 243, 100, 129, 149, 125, 206, 44, 55, 150, 198, 186, 71, 79>>
      assert Ecto.ULID.extract_timestamp(ulid) == @timestamp
    end

    test "extracts a timestamp from a uuid ulid" do
      uuid = "01563df3-6481-957d-ce2c-3796c6ba474f"
      assert Ecto.ULID.extract_timestamp(uuid) == @timestamp
    end
  end

  describe "to_uuid/1" do
    test "converts ULID to UUID" do
      uuid = Ecto.ULID.generate(@timestamp) |> Ecto.ULID.to_uuid()
      assert String.length(uuid) == 36
      assert binary_part(uuid, 0, 8) == "01563df3"
    end

    test "converts raw ulid to uuid" do
      uuid = Ecto.ULID.bingenerate(@timestamp) |> Ecto.ULID.to_uuid()
      assert String.length(uuid) == 36
      assert binary_part(uuid, 0, 8) == "01563df3"
    end
  end

  describe "cast/1" do
    test "returns valid ULID" do
      {:ok, ulid} = Ecto.ULID.cast(@encoded)
      assert ulid == @encoded
    end

    test "returns valid ULID when a UUID encoded string is passed" do
      {:ok, ulid} = Ecto.ULID.cast(@encoded)
      assert {:ok, ^ulid} = Ecto.ULID.cast(@encoded_uuid)
    end

    test "returns ULID for encoding of correct length" do
      {:ok, ulid} = Ecto.ULID.cast("00000000000000000000000000")
      assert ulid == "00000000000000000000000000"
    end

    test "returns error when encoding is too short" do
      assert Ecto.ULID.cast("0000000000000000000000000") == :error
    end

    test "returns error when encoding is too long" do
      assert Ecto.ULID.cast("000000000000000000000000000") == :error
    end

    test "returns error when encoding contains letter I" do
      assert Ecto.ULID.cast("I0000000000000000000000000") == :error
    end

    test "returns error when encoding contains letter L" do
      assert Ecto.ULID.cast("L0000000000000000000000000") == :error
    end

    test "returns error when encoding contains letter O" do
      assert Ecto.ULID.cast("O0000000000000000000000000") == :error
    end

    test "returns error when encoding contains letter U" do
      assert Ecto.ULID.cast("U0000000000000000000000000") == :error
    end

    test "returns error for invalid encoding" do
      assert Ecto.ULID.cast("$0000000000000000000000000") == :error
    end

    test "returns error when UUID encoding is too short" do
      assert Ecto.ULID.cast("015fc23c-6c49-d172-88ec-85736ac3911") == :error
    end

    test "returns error when UUID encoding is too long" do
      assert Ecto.ULID.cast("015fc23c-6c49-d172-88ec-85736ac391166") == :error
    end

    test "returns error for invalid UUID encoding" do
      assert Ecto.ULID.cast("z15fc23c-6c49-d172-88ec-85736ac39116") == :error
    end
  end

  describe "dump/1" do
    test "dumps valid ULID to binary" do
      {:ok, bytes} = Ecto.ULID.dump(@encoded)
      assert bytes == @binary
    end

    test "dumps encoding of correct length" do
      {:ok, bytes} = Ecto.ULID.dump("00000000000000000000000000")
      assert bytes == <<0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0>>
    end

    test "dumps valid UUID hex representation to binary" do
      {:ok, bytes_1} = Ecto.ULID.dump(@encoded)
      {:ok, bytes_2} = Ecto.ULID.dump(@encoded_uuid)
      assert bytes_1 == bytes_2
    end

    test "returns error when encoding is too short" do
      assert Ecto.ULID.dump("0000000000000000000000000") == :error
    end

    test "returns error when encoding is too long" do
      assert Ecto.ULID.dump("000000000000000000000000000") == :error
    end

    test "returns error when encoding contains letter I" do
      assert Ecto.ULID.dump("I0000000000000000000000000") == :error
    end

    test "returns error when encoding contains letter L" do
      assert Ecto.ULID.dump("L0000000000000000000000000") == :error
    end

    test "returns error when encoding contains letter O" do
      assert Ecto.ULID.dump("O0000000000000000000000000") == :error
    end

    test "returns error when encoding contains letter U" do
      assert Ecto.ULID.dump("U0000000000000000000000000") == :error
    end

    test "returns error for invalid encoding" do
      assert Ecto.ULID.dump("$0000000000000000000000000") == :error
    end
  end

  describe "load/1" do
    test "encodes binary as ULID" do
      {:ok, encoded} = Ecto.ULID.load(@binary)
      assert encoded == @encoded
    end

    test "encodes binary of correct length" do
      {:ok, encoded} = Ecto.ULID.load(<<0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0>>)
      assert encoded == "00000000000000000000000000"
    end

    test "returns error when data is too short" do
      assert Ecto.ULID.load(<<0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0>>) == :error
    end

    test "returns error when data is too long" do
      assert Ecto.ULID.load(<<0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0>>) == :error
    end
  end
end
