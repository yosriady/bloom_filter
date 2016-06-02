# BloomFilter

Bloom Filter implementation in Elixir. Bloom filters are probabilistic data structures designed
to efficiently tell you whether an element is present in a set.

[![Travis](https://travis-ci.org/yosriady/bloom_filter.svg)](https://travis-ci.org/yosriady/bloom_filter)
[![Coverage Status](https://coveralls.io/repos/github/yosriady/bloom_filter/badge.svg?branch=master)](https://coveralls.io/github/yosriady/bloom_filter?branch=master)
[![Hex.pm](https://img.shields.io/hexpm/v/bloom_filter.svg?maxAge=2592000)](https://hex.pm/packages/bloom_filter)

### [Hex](http://hex.pm/packages/bloom_filter)
### [API Documentation](https://hexdocs.pm/bloom_filter/)

## Installation

Add bloom_filter to your list of dependencies in `mix.exs`:

        def deps do
          [{:bloom_filter, "~> 1.0.0"}]
        end

## Usage

    iex> f = BloomFilter.new 100, 0.001 # Create a bloom filter with an expected capacity 100 and desired false positive rate < 0.001
    iex> f = BloomFilter.add(f, 42)
    iex> BloomFilter.has?(f, 42)
    true

## Running Tests

```
mix test
```

## Background

A [Bloom filter](https://en.wikipedia.org/wiki/Bloom_filter) is a space-efficient data structure designed to efficiently tell you whether an element is present in a set. Both insertion and membership operations theoretically cost a constant time `O(k)`, where `k` is the number of hash functions used in the filter.

The price paid for this efficiency is that a Bloom filter is a probabilistic data structure: it tells us that the element either is *definitely NOT in* the set or *MAYBE in* the set.

![](https://upload.wikimedia.org/wikipedia/commons/thumb/a/ac/Bloom_filter.svg/360px-Bloom_filter.svg.png)

The filter is essentially a vector of bits (`0` or `1`) of some size `m`. When we `add` a new `item` to the filter we map `item` to `k` number of hash functions, which gives us `k` indices. We then set the bits on these indices to `1`.

When we want to check if our filter `has?` a particular `item`, we feed it to our hash functions again, and check if `any?` of the bits are `0` or `all?` the bits are `1`. If there are bits that are not set, `item` is **definitely** not in the set. If all the bits are set, `item` is **probably** in the set, since false positives can happen due to [collision](https://en.wikipedia.org/wiki/Collision_(computer_science)).

Bloom filters are best suited for applications where the amount of source data would require an impractically large amount of memory if "conventional" error-free hashing techniques were applied.

## Implementation Details

`bloom_filter` uses two hash functions [`:erlang.phash2`](http://erlang.org/doc/man/erlang.html#phash2-2),  [`Fowler–Noll–Vo`](https://en.wikipedia.org/wiki/Fowler%E2%80%93Noll%E2%80%93Vo_hash_function), and the [Double Hashing](https://en.wikipedia.org/wiki/Double_hashing) technique to generate an arbitrary number of independent hash functions.

`bloom_filter` also automatically optimizes the optimal size of the bit vector and the number of hash functions required to attain the user's desired error rate.

## Running Type Checker

> You need to have [dialyxir](https://github.com/jeremyjh/dialyxir) installed.

```
mix dialyzer
```

## Contributing

1. Fork it ( http://github.com/Leventhan/bloom_filter/fork )
2. Create your feature branch (`git checkout -b feature/my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin feature/my-new-feature`)
5. Create new Pull Request (Remember to squash your commits!)

> Report any found bugs or errors using [the issue tracker](https://github.com/Leventhan/bloom_filter/issues).

## License

Copyright (c) 2016 Yos Riady

Permission is hereby granted, free of charge, to any person obtaining
a copy of this software and associated documentation files (the
"Software"), to deal in the Software without restriction, including
without limitation the rights to use, copy, modify, merge, publish,
distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so, subject to
the following conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
