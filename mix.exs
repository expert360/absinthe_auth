defmodule AbsintheAuth.MixProject do
  use Mix.Project

  def project do
    [
      app: :absinthe_auth,
      name: "AbsintheAuth",
      version: "0.1.0",
      elixir: "~> 1.6",
      elixirc_paths: elixirc_paths(Mix.env()),
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      package: package(),
      description: description(),
      test_coverage: [tool: ExCoveralls],
      docs: [
        main: "readme",
        extras: ["README.md"]
      ],
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp description do
    "Authorisation framework for Absinthe GraphQL"
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:absinthe, "~> 1.4"},
      {:ex_doc, "~> 0.18.4"},
      {:inch_ex, ">= 0.0.0", only: :docs},
      {:excoveralls, "~> 0.9.1", only: :test}
    ]
  end

  defp package do
    [
      files: ~w(lib mix.exs README.md LICENSE.md),
      links: %{"GitHub" => "https://github.com/expert360/absinthe_auth"},
      licenses: ["Apache 2.0"],
      maintainers: ["Dan Draper"],
    ]
  end
end
