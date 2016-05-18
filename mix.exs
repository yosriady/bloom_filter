defmodule BloomFilter.Mixfile do
  use Mix.Project

  def project do
    [app: :bloom_filter,
     version: "1.0.0",
     elixir: "~> 1.2",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     description: description,
     package: package,
     deps: deps]
  end

  defp description do
    """
    Bloom Filter implementation in Elixir. Bloom filters are probabilistic data structures designed
    to efficiently tell you whether an element is present in a set.
    """
  end

  defp package do
    [
     files: ["lib", "mix.exs", "README.md"],
     maintainers: ["Yos Riady"],
     licenses: ["Apache 2.0"],
     links: %{"GitHub" => "https://github.com/Leventhan/bloom_filter",
              "Docs" => "http://hexdocs.pm/bloom_filter/"}
     ]
  end

  # Configuration for the OTP application
  #
  # Type "mix help compile.app" for more information
  def application do
    [applications: [:logger]]
  end

  # Dependencies can be Hex packages:
  #
  #   {:mydep, "~> 0.3.0"}
  #
  # Or git/path repositories:
  #
  #   {:mydep, git: "https://github.com/elixir-lang/mydep.git", tag: "0.1.0"}
  #
  # Type "mix help deps" for more examples and options
  defp deps do
    [{:math, "~> 0.2.0"},
     {:fnv, "~> 0.3.2 "},
     {:ex_doc, "~> 0.11", only: :dev},
     {:earmark, "~> 0.1", only: :dev},
     {:dialyxir, "~> 0.3", only: [:dev]}]
  end
end
