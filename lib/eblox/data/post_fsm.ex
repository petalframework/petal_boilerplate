defmodule Eblox.Data.PostFSM do
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

  @interval_after_parse 60_000

  def on_transition(:idle, :read, nil, %{file: file} = payload) do
    case File.read(file) do
      {:ok, content} -> {:ok, :read, Map.put(payload, :content, content)}
      {:error, _reason} -> :error
    end
  end

  def on_transition(:read, :parse, nil, %{content: content} = payload) do
    case Md.parse(content) do
      %Md.Parser.State{} = parsed ->
        payload =
          payload
          |> Map.put(:md, parsed)
          |> Map.put(:html, Md.generate(parsed, Md.Parser.Default, format: :none))

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
