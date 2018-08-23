defmodule AbsintheAuth.MixProject do
  use Mix.Project

  def project do
    [
      app: :absinthe_auth,
      version: "0.1.0",
      elixir: "~> 1.6",
      elixirc_paths: elixirc_paths(Mix.env()),
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      name: "AbsintheAuth",
      docs: [
        main: "readme",
        extras: ["README.md"]
      ]
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
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
end
