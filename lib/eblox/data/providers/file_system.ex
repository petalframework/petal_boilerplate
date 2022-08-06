defmodule Eblox.Data.Providers.FileSystem do
  @moduledoc false

  alias Eblox.Data.Provider

  @type md5 :: <<_::256>>

  @behaviour Provider

  @impl Provider
  def scan(options) do
    content_dir = Map.get(options, :content_dir, File.cwd())
    old_files = Map.get(options, :resources, %{})

    files =
      content_dir
      |> file_list()
      |> Flow.from_enumerable()
      |> Flow.partition()
      |> Flow.reduce(fn -> %{} end, fn file, acc ->
        file
        |> File.read()
        |> case do
          {:ok, content} -> Map.put(acc, file, md5(content))
          _ -> acc
        end
      end)
      |> Map.new()

    {Map.put(options, :resources, files), diff(files, old_files)}
  end

  @spec file_list(Path.t()) :: [Path.t()]
  defp file_list(directory) do
    dig = fn
      {:ok, files}, path -> Enum.flat_map(files, &file_list(Path.join(path, &1)))
      {:error, _}, path -> [path]
    end

    if String.contains?(directory, ".git"), do: [], else: dig.(File.ls(directory), directory)
  end

  @spec diff(%{Path.t() => md5()}, %{Path.t() => md5()}) :: Provider.t()
  defp diff(map, map), do: %Provider{}

  defp diff(new, old) do
    keys = MapSet.new(Map.keys(new) ++ Map.keys(old))

    Enum.reduce(keys, diff(%{}, %{}), fn key, acc ->
      case {Map.fetch(new, key), Map.fetch(old, key)} do
        {{:ok, value}, {:ok, value}} -> acc
        {:error, {:ok, _}} -> %Provider{acc | deleted: [key | acc.deleted]}
        {{:ok, _}, :error} -> %Provider{acc | created: [key | acc.created]}
        {{:ok, _}, {:ok, _}} -> %Provider{acc | changed: [key | acc.changed]}
      end
    end)
  end

  @spec md5(binary()) :: <<_::256>>
  def md5(content) do
    :md5
    |> :crypto.hash(content)
    |> Base.encode16(case: :lower)
  end
end
