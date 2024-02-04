defmodule KinoYoutube.MixProject do
  use Mix.Project

  def project do
    [
      app: :kino_youtube,
      version: "0.1.0",
      elixir: "~> 1.14",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      description:
        "A simple Kino that wraps the YouTube Embedded iFrame API to render a YouTube player in a Livebook.",
      source_url: "https://github.com/acalejos/kino_youtube",
      homepage_url: "https://github.com/acalejos/kino_youtube",
      package: package()
    ]
  end

  defp package do
    [
      maintainers: ["Andres Alejos"],
      licenses: ["MIT"],
      links: %{"GitHub" => "https://github.com/acalejos/kino_youtube"}
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:kino, "~> 0.12"},
      {:ex_doc, ">= 0.0.0", only: :dev, runtime: false}
    ]
  end
end
