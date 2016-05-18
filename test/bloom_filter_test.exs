defmodule BloomFilterTest do
  use ExUnit.Case
  doctest BloomFilter

  test "has? for a nonexistent element should return false" do
    f = BloomFilter.new 100, 0.001
    assert BloomFilter.has?(f, 42) == false
  end

  test "basic adding and membership scenario" do
    f = BloomFilter.new 100, 0.001
    f = BloomFilter.add(f, 42)
    assert BloomFilter.has?(f, 42) == true
    assert BloomFilter.has?(f, "missing") == false
  end
end
