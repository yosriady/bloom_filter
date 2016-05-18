# BloomFilter

Bloom Filter implementation in Elixir. Bloom filters are probabilistic data structures designed
to efficiently tell you whether an element is present in a set.

## Installation

    Add bloom_filter to your list of dependencies in `mix.exs`:

        def deps do
          [{:bloom_filter, "~> 1.0.0"}]
        end

## Usage

    iex> f = BloomFilter.new 100, 0.001
    iex> f = BloomFilter.add(f, 42)
    iex> BloomFilter.has?(f, 42)
    true
