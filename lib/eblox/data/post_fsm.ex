defmodule Eblox.Data.PostFSM do
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

  def on_transition(:idle, :read, nil, %{file: file} = payload) do
    case File.read(file) do
      {:ok, content} -> {:ok, :read, Map.put(payload, :content, content)}
      {:error, _reason} -> :error
    end
  end

  @behaviour Siblings.Worker

  @impl Siblings.Worker
  def perform(:idle, _id, _payload) do
    {:transition, :read, nil}
  end

  def perform(state, id, payload) do
    ["[PERFORM] ", state, id, payload]
    |> inspect()
    |> Logger.info()
  end
end
