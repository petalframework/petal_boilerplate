defmodule Eblox.Data.Post do
  @moduledoc """
  The process backing up content
  """

  require Logger

  @fsm """
  idle --> |read| read
  idle --> |delete| deleted
  read --> |parse| parsed
  read --> |parse| errored
  read --> |delete| deleted
  parsed --> |delete| deleted
  parsed --> |parse| parsed
  parsed --> |parse| errored
  errored --> |delete| deleted
  """

  use Finitomata, @fsm

  defmodule Tag do
    @moduledoc false
    @behaviour Md.Transforms

    @href "/tags/"

    @impl Md.Transforms
    def apply(md, text) do
      href = @href <> URI.encode_www_form(text)
      tag = String.downcase(text)
      {:a, %{class: "tag", "data-tag": tag, href: href}, [md <> text]}
    end
  end

  defmodule EbloxParser do
    @moduledoc false

    @tag_terminators [:ascii_punctuation]
    @eblox_syntax Md.Parser.Syntax.merge(
                    Application.compile_env(:eblox_syntax, :md_syntax, %{
                      magnet: [
                        {"%", %{transform: Tag, terminators: @tag_terminators, greedy: false}}
                      ]
                    })
                  )

    use Md.Parser, syntax: @eblox_syntax
  end

  defmodule Walker do
    @moduledoc false
    def prewalk({:a, %{class: "tag", "data-tag": tag}, _text} = elem, acc) do
      {elem, Map.update(acc, :tags, [tag], &Enum.uniq([tag | &1]))}
    end

    def prewalk(elem, acc),
      do: {elem, acc}
  end

  @interval_after_parse 60_000
  @default_properties %{tags: []}

  def on_transition(:idle, :read, nil, %{file: file} = payload) do
    case File.read(file) do
      {:ok, content} -> {:ok, :read, Map.put(payload, :content, content)}
      {:error, _reason} -> :error
    end
  end

  def on_transition(:read, :parse, nil, %{content: content} = payload) do
    case EbloxParser.parse(content) do
      {"", %Md.Parser.State{} = parsed} ->
        {html, properties} = Md.generate(parsed, walker: &Walker.prewalk/2, format: :none)

        payload =
          payload
          |> Map.put(:md, parsed)
          |> Map.put(:html, html)
          |> Map.put(:properties, Map.merge(@default_properties, properties))

        {:ok, :parsed, payload}

      _other ->
        :error
    end
  end

  @behaviour Siblings.Worker

  @impl Siblings.Worker
  def perform(:idle, _id, _payload) do
    {:transition, :read, nil}
  end

  @impl Siblings.Worker
  def perform(:read, _id, _payload) do
    {:transition, :parse, nil}
  end

  def perform(:parsed, _id, _payload) do
    {:reschedule, @interval_after_parse}
  end

  def perform(state, id, payload) do
    ["[PERFORM] ", state, id, payload]
    |> inspect()
    |> Logger.info()

    :noop
  end
end
