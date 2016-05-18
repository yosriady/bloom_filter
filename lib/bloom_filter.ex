require Math

defmodule BloomFilter do
  @moduledoc """
    A Bloom filter allows you to test whether an element belongs in a set or not.
  """
  defstruct [:bits, :num_bits, :capacity, :error_rate, :hash_functions]

  @doc """
    Creates a new bloom filter.

    ## Example

      f = BloomFilter.new 100, 0.001
  """
  def new(capacity, error_rate) do
    {m, k, _} = optimize(capacity, error_rate)
    bits = (for _ <- 1..m, do: 0)
    hash_functions = make_hashes(m, k)
    %BloomFilter{ bits: bits, num_bits: m, capacity: capacity,
                  error_rate: error_rate, hash_functions: hash_functions}
  end

  @doc """
    Checks whether a given item is likely to exist in the set.

    ## Example

      iex> f = BloomFilter.new 100, 0.001
      iex> f = BloomFilter.add(f, 42)
      iex> BloomFilter.has?(f, 42)
      true
  """
  def has?(%BloomFilter{bits: bits, hash_functions: hash_functions}, item) do
    item_bits = hash(hash_functions, item)
    item_bits
    |> Enum.map(fn(x) -> Enum.at(bits, x) end)
    |> Enum.all?(fn(x) -> x == 1 end)
  end

  @doc """
    Adds a given item to the set.

    ## Example

      f = BloomFilter.new 100, 0.001
      f = BloomFilter.add(f, 42)
  """
  def add(%BloomFilter{bits: bits, hash_functions: hash_functions} = bloom, item) do
    item_bits = hash(hash_functions, item)
    new_bits = item_bits
      |> Enum.reduce(bits, fn(index, vector) -> List.replace_at(vector, index, 1) end)
    %{bloom | bits: new_bits}
  end

  @doc """
    Approximates the number of items in the filter.
  """
  def count(%BloomFilter{bits: bits, num_bits: num_bits, hash_functions: hash_functions}) do
    num_truthy_bits = Enum.count(bits, fn(x) -> x == 1 end)
    approximate_size(num_bits, Enum.count(hash_functions), num_truthy_bits)
  end

  # Approximates the number of items in the filter with m bits, k hash functions,
  # and x bits set to 1.
  # https://en.wikipedia.org/wiki/Bloom_filter#Approximating_the_number_of_items_in_a_Bloom_filter
  def approximate_size(m, k, x) do
    -(m * (Math.log (1 - x/m), Math.e))/k
  end

  # Calculates the false positive rate given m bits, k hash functions, and n elements
  # https://en.wikipedia.org/wiki/Bloom_filter#Probability_of_false_positives
  defp false_positive_rate(m, n, k) do
    Math.pow (1 - Math.pow(Math.e, -k*(n+0.5)/(m-1))), k
  end

  # Calculates the optimal number of hash functions k given m bits and capacity n
  # https://en.wikipedia.org/wiki/Bloom_filter#Optimal_number_of_hash_functions
  defp optimal_hash_functions(m, n) do
    (m/n) * Math.log Math.e, 2
  end

  # Calculates optimal bloom filter size m and number of hash functions k
  defp optimize(n, error_rate) do
    optimize_values(n, n*4, 2, error_rate)
  end

  # Recursively calculates the optimal bloom filter parameters until the desired
  # error rate is attained
  defp optimize_values(n, m, k, required_error_rate) do
    error_rate = false_positive_rate(m, n, k)
    acceptable_error_rate? = error_rate < required_error_rate
    cond do
      acceptable_error_rate? ->
        {m, (k |> Float.ceil |> round), error_rate}
      true ->
        optimize_values(n, m*2, optimal_hash_functions(m*2, n), error_rate)
    end
  end

  # Generates k hash functions
  defp make_hashes(m, k) do
    Enum.map(1..k, fn(i) -> make_hash_i(i, m) end)
  end

  # Generates a new i-th hash function for a filter of size m bits
  # https://en.wikipedia.org/wiki/Double_hashing
  # https://en.wikipedia.org/wiki/Fowler-Noll-Vo_hash_function
  defp make_hash_i(i, m) do
    fn(item) -> rem (:erlang.phash2(item, Math.pow(2,32)) + i * FNV.FNV1a.hash(Kernel.inspect(item), 128)), m end
  end

  # Returns a list of the result of applying every function in hash_functions to item
  defp hash(hash_functions, item) do
    Enum.map(hash_functions, fn(h) -> h.(item) end)
  end
end
