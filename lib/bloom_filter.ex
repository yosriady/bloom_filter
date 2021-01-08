require Math

defmodule BloomFilter do
  @moduledoc """
    Bloom Filter implementation in Elixir. Bloom filters are probabilistic data structures designed
    to efficiently tell you whether an element is present in a set.

        ## Usage Example

          iex> f = BloomFilter.new 100, 0.001
          iex> f = BloomFilter.add(f, 42)
          iex> BloomFilter.has?(f, 42)
          true
  """
  defstruct [:bits, :num_bits, :capacity, :error_rate, :hash_functions]

  @type bit :: 0 | 1
  @type hash_func :: (any -> pos_integer)
  @type t :: %BloomFilter{
          bits: [bit, ...],
          num_bits: pos_integer,
          capacity: pos_integer,
          error_rate: float,
          hash_functions: [hash_func, ...]
        }

  @doc """
    Creates a new bloom filter, given an estimated number of elements and a desired error rate (0.0..1).
  """
  @spec new(pos_integer, float) :: t
  def new(capacity, error_rate)
      when error_rate > 0 and error_rate < 1 do
    {m, k, _} = optimize(capacity, error_rate)
    bits = for _ <- 1..m, do: 0
    hash_functions = make_hashes(m, k)

    %BloomFilter{
      bits: bits,
      num_bits: m,
      capacity: capacity,
      error_rate: error_rate,
      hash_functions: hash_functions
    }
  end

  @doc """
    Checks whether a given item is likely to exist in the set.
  """
  @spec has?(t, any) :: boolean
  def has?(%BloomFilter{bits: bits, hash_functions: hash_functions}, item) do
    item_bits = hash(hash_functions, item)

    item_bits
    |> Enum.map(fn x -> Enum.at(bits, x) end)
    |> Enum.all?(fn x -> x == 1 end)
  end

  @doc """
    Adds a given item to the set.
  """
  @spec add(t, any) :: t
  def add(%BloomFilter{bits: bits, hash_functions: hash_functions} = bloom, item) do
    item_bits = hash(hash_functions, item)

    new_bits =
      item_bits
      |> Enum.reduce(bits, fn index, vector -> List.replace_at(vector, index, 1) end)

    %{bloom | bits: new_bits}
  end

  @doc """
    Approximates the number of items in the filter.
  """
  @spec count(t) :: float
  def count(%BloomFilter{bits: bits, num_bits: num_bits, hash_functions: hash_functions}) do
    num_truthy_bits = Enum.count(bits, fn x -> x == 1 end)
    approximate_size(num_bits, Enum.count(hash_functions), num_truthy_bits)
  end

  # Approximates the number of items in the filter with m bits, k hash functions,
  # and x bits set to 1.
  # https://en.wikipedia.org/wiki/Bloom_filter#Approximating_the_number_of_items_in_a_Bloom_filter
  @spec approximate_size(pos_integer, pos_integer, non_neg_integer) :: float
  defp approximate_size(m, k, x) do
    -(m * Math.log(1 - x / m, Math.e())) / k
  end

  # Calculates the false positive rate given m bits, n elements, and k hash functions
  # https://en.wikipedia.org/wiki/Bloom_filter#Probability_of_false_positives
  @spec false_positive_rate(pos_integer, pos_integer, number) :: float
  defp false_positive_rate(m, n, k) do
    Math.pow(1 - Math.pow(Math.e(), -k * (n + 0.5) / (m - 1)), k)
  end

  # Calculates the optimal number of hash functions k given m bits and capacity n
  # https://en.wikipedia.org/wiki/Bloom_filter#Optimal_number_of_hash_functions
  @spec optimal_hash_functions(pos_integer, pos_integer) :: float
  defp optimal_hash_functions(m, n) do
    m / n * Math.log(Math.e(), 2)
  end

  # Calculates optimal bloom filter size m and number of hash functions k
  @spec optimize(pos_integer, float) :: {pos_integer, pos_integer, float}
  defp optimize(n, error_rate) do
    optimize_values(n, n * 4, 2, error_rate)
  end

  # Recursively calculates the optimal bloom filter parameters until the desired
  # error rate is attained
  @spec optimize_values(pos_integer, pos_integer, number, float) :: {pos_integer, integer, float}
  defp optimize_values(n, m, k, required_error_rate) do
    error_rate = false_positive_rate(m, n, k)
    acceptable_error_rate? = error_rate < required_error_rate

    cond do
      acceptable_error_rate? ->
        {m, k |> Float.ceil() |> round, error_rate}

      true ->
        optimize_values(n, m * 2, optimal_hash_functions(m * 2, n), error_rate)
    end
  end

  # Generates k hash functions
  @spec make_hashes(pos_integer, pos_integer) :: [hash_func, ...]
  defp make_hashes(m, k) do
    Enum.map(1..k, fn i -> make_hash_i(i, m) end)
  end

  # Generates a new i-th hash function for a filter of size m bits
  # https://en.wikipedia.org/wiki/Double_hashing
  # https://en.wikipedia.org/wiki/Fowler-Noll-Vo_hash_function
  @spec make_hash_i(pos_integer, pos_integer) :: hash_func
  defp make_hash_i(i, m) do
    fn item ->
      rem(
        :erlang.phash2(item, Math.pow(2, 32)) + i * FNV.FNV1a.hash(Kernel.inspect(item), 128),
        m
      )
    end
  end

  # Returns a list of the result of applying every function in hash_functions to item
  @spec hash([hash_func, ...], any) :: [pos_integer, ...]
  defp hash(hash_functions, item) do
    Enum.map(hash_functions, fn h -> h.(item) end)
  end
end
