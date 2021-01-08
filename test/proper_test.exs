defmodule ProperTest do
  use ExUnit.Case
  use PropCheck

  @error_rate 0.001

  property "all added elements exist" do
    forall items <- non_empty(list(integer())) do
      size = min(10 * length(items), 100)
      filter = BloomFilter.new(size, @error_rate)

      filter =
        items
        |> Enum.reduce(filter, fn item, f ->
          BloomFilter.add(f, item)
        end)

      all_found =
        items
        |> Enum.reduce(true, fn item, found ->
          found and BloomFilter.has?(filter, item)
        end)

      assert all_found
      assert_count(filter, items)
    end
  end

  defp assert_count(filter, items) do
    delta = abs(BloomFilter.count(filter) - length(items))
    assert delta < 10
  end
end
