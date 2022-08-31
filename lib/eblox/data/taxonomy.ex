defmodule Eblox.Data.Taxonomy do
  @moduledoc """
  A behaviour specifying the data taxonomy to be plugged into `Eblox`.

  Taxonomies define how the data collected by data providers is organized
  into hierarchies or other structures and indexed. Clients can subscribe on
  taxonomy updates to be in sync with data represented by a taxonomy.
  """
  use Supervisor

  @typedoc "Taxonomy option."
  @type option() :: {:impl, module()} | {:name, module()}

  @typedoc "Identifier of a Post's FSM worker process."
  @type post_id() :: Siblings.Worker.id()

  @typedoc "Options used for `Registry.start_link/1`."
  @type registry_option() :: Registry.start_option()

  @typedoc "Taxonomy registry key."
  @type registry_key() :: term()

  @typedoc "Taxonomy registry value."
  @type registry_value() :: term()

  @doc "A function to specify `Registry` options used for a taxonomy implementation."
  @callback registry_options([registry_option()]) :: [registry_option()]

  @doc "A function which adds a new node to a taxonomy for a specific implementation."
  @callback on_add(module(), post_id()) :: :ok | :error

  @doc "A function which removes a node from a taxonomy for a specific implementation."
  @callback on_remove(module(), post_id()) :: :ok

  defmodule Meta do
    @moduledoc """
    Taxonomy metadata.
    """

    use Agent

    alias Eblox.Data.Taxonomy.Meta

    @type t :: %{
            __struct__: Meta,
            impl: module()
          }
    @enforce_keys ~w|impl|a
    defstruct ~w|impl|a

    def start_link(opts) do
      {impl, opts} = Keyword.pop!(opts, :impl)

      Agent.start_link(fn -> %Meta{impl: impl} end, opts)
    end

    def impl(name) do
      Agent.get(name, & &1.impl)
    end
  end

  @doc false
  @spec start_link([option()]) :: Supervisor.on_start()
  def start_link(opts), do: Supervisor.start_link(__MODULE__, opts)

  @impl Supervisor
  def init(opts) do
    {impl, opts} = Keyword.pop!(opts, :impl)
    {name, _opts} = Keyword.pop(opts, :name, impl)

    children = [
      {Meta, impl: impl, name: meta_name(name)},
      {Registry, impl.registry_options(name: reg_name(name))}
      # {PubSub, name: pubsub_name(name)}
    ]

    Supervisor.init(children, name: sup_name(name), strategy: :one_for_one)
  end

  @doc "Adds a new node to a taxonomy for a given post ID."
  @spec add(module(), post_id()) :: :ok | :error
  def add(name, post_id) do
    impl(name).on_add(reg_name(name), post_id)
  end

  @doc "Removes a node associated with a given post ID from a taxonomy."
  @spec remove(module(), post_id()) :: :ok | :error
  def remove(name, post_id) do
    impl(name).on_remove(reg_name(name), post_id)
  end

  @doc "Finds a list of matching node values in a taxonomy by key."
  @spec lookup(module(), registry_key()) :: [registry_value()]
  def lookup(name, key) do
    name
    |> reg_name()
    |> Registry.lookup(key)
    |> Enum.map(&elem(&1, 1))
  end

  @doc "Returns keys of a taxonomy."
  @spec keys(module()) :: [registry_key()]
  def keys(name) do
    name
    |> reg_name()
    |> Registry.keys(self())
    |> Enum.uniq()
  end

  @doc "Returns values of a taxonomy for the given key."
  @spec values(module(), registry_key()) :: [registry_value()]
  def values(name, key) do
    name |> reg_name() |> Registry.values(key, self())
  end

  @doc "Converts registry to a map with keys and lists of values."
  @spec to_map(module()) :: %{registry_key() => [registry_value()]}
  def to_map(name) do
    name
    |> reg_name()
    |> Registry.select([{{:"$1", :_, :"$2"}, [], [{{:"$1", :"$2"}}]}])
    |> Enum.group_by(&elem(&1, 0), &elem(&1, 1))
  end

  defp impl(name) do
    name
    |> meta_name()
    |> Meta.impl()
  end

  defp sup_name(name), do: Module.concat(name, "Supervisor")
  defp meta_name(name), do: Module.concat(name, "Meta")
  defp reg_name(name), do: Module.concat(name, "Registry")
end
