defmodule KinoYouTube do
  @moduledoc """
  A simple Kino that wraps the YouTube Embedded iFrame API to render a YouTube player
  in a Livebook.

  This Kino consists of only one function, `KinoYouTube.new/2`.

  Refer to the [YouTube documentation](https://developers.google.com/youtube/player_parameters#Parameters) for a list of accepted parameters
  """
  use Kino.JS
  use Kino.JS.Live

  @valid_params %{
    autoplay: [0, 1],
    # Expecting a ISO 639-1 two-letter language code.
    cc_lang_pref: :string,
    cc_load_policy: [0, 1],
    color: [:red, :white],
    controls: [0, 1],
    disablekb: [0, 1],
    enablejsapi: [0, 1],
    end: :integer,
    fs: [0, 1],
    # ISO 639-1 two-letter language code or a fully specified locale.
    hl: :string,
    iv_load_policy: [1, 3],
    list: :string,
    listType: [:playlist, :user_uploads],
    loop: [0, 1],
    origin: :string,
    playlist: :string,
    playsinline: [0, 1],
    rel: [0, 1],
    start: :integer,
    widget_referrer: :string
  }

  def validate_and_assign_defaults(opts) when is_list(opts) do
    Enum.reduce(@valid_params, [], fn {param, valid_values}, acc ->
      case Keyword.fetch(opts, param) do
        {:ok, value} when valid_values == :string ->
          [{param, value} | acc]

        {:ok, value} when valid_values == :integer and is_integer(value) ->
          [{param, value} | acc]

        {:ok, value} when is_list(valid_values) ->
          if value in valid_values, do: [{param, value} | acc], else: :error

        # Assign default if missing
        :error when is_list(valid_values) ->
          [{param, Enum.fetch!(valid_values, 0)} | acc]

        # Skip if no default and not required
        :error ->
          acc

        _ ->
          raise "#{param} has an invalid value"
      end
    end)
    # To maintain the original order
    |> Enum.reverse()
  end

  def new(url, params \\ []) do
    {height, params} = Keyword.pop(params, :height, 315)
    {width, params} = Keyword.pop(params, :width, 560)
    params = validate_and_assign_defaults(params)

    video_id =
      Regex.run(
        ~r'^.*((youtu.be\/)|(v\/)|(\/u\/\w\/)|(embed\/)|(watch\?))\??v?=?([^#&?]*).*',
        url
      )
      |> Enum.reverse()
      |> hd

    param_str = Enum.into(params, <<>>, fn {k, v} -> "#{k}=#{v}&" end)

    iframe = """
    <iframe width="#{width}" height="#{height}" src="https://www.youtube.com/embed/#{video_id}?#{param_str}" title="Kino YouTube" frameborder="0" allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture; web-share" allowfullscreen></iframe>
    """

    Kino.JS.Live.new(__MODULE__, iframe, params)
  end

  @impl true
  def init(iframe, ctx) do
    {:ok, assign(ctx, iframe: iframe)}
  end

  @impl true
  def handle_connect(ctx) do
    {:ok, ctx.assigns.iframe, ctx}
  end

  asset "main.js" do
    """
    export function init(ctx, iframe) {
      ctx.root.innerHTML = iframe;
    }
    """
  end
end
