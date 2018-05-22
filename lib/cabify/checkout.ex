defmodule Cabify.Checkout do
  use GenServer

  alias Cabify.Product

  def start_link do
    GenServer.start_link(
      __MODULE__,
      [
        {:ets_table_name, :checkout},
        {:log_limit, 1_000_000}
      ],
      name: __MODULE__
    )
  end

  def scan(product) do
    case get(product) do
      {:not_found} -> set(product, 1)
      {:found, result} -> set(product, result + 1)
    end
  end

  def all do
    GenServer.call(__MODULE__, {:all})
  end

  def total do
    products = GenServer.call(__MODULE__, {:all})

    total =
      Enum.reduce(products, 0, fn {product, qty}, acc ->
        Product.calc({product, qty}) + acc
      end)

    # credo:disable-for-lines:4 Credo.Check.Refactor.PipeChainStart
    (total / 100)
    |> Decimal.new()
    |> Decimal.round(2)
    |> Decimal.to_float()
  end

  defp get(product) do
    case GenServer.call(__MODULE__, {:get, product}) do
      [] -> {:not_found}
      [{_product, result}] -> {:found, result}
    end
  end

  defp set(product, qty) do
    GenServer.call(__MODULE__, {:set, product, qty})
  end

  ## Callbacks
  def init(args) do
    [{:ets_table_name, ets_tbl_n}, {:log_limit, log_limit}] = args

    :ets.new(ets_tbl_n, [:named_table, :set, :private])

    {:ok, %{log_limit: log_limit, ets_table_name: ets_tbl_n}}
  end

  def terminate(_, state) do
    %{ets_table_name: ets_tbl_n} = state

    :ets.delete(ets_tbl_n)
  end

  def handle_call({:get, product}, _from, state) do
    %{ets_table_name: ets_tbl_n} = state

    result = :ets.lookup(ets_tbl_n, product)

    {:reply, result, state}
  end

  def handle_call({:set, product, qty}, _from, state) do
    %{ets_table_name: ets_tbl_n} = state

    true = :ets.insert(ets_tbl_n, {product, qty})

    {:reply, qty, state}
  end

  def handle_call({:all}, _from, state) do
    %{ets_table_name: ets_tbl_n} = state

    stream =
      Stream.resource(
        fn -> :ets.first(ets_tbl_n) end,
        fn
          :"$end_of_table" -> {:halt, nil}
          prev_key -> {:ets.lookup(ets_tbl_n, prev_key), :ets.next(ets_tbl_n, prev_key)}
        end,
        fn _ -> :ok end
      )

    {:reply, Enum.to_list(stream), state}
  end

  def handle_info(:bye, state) do
    {:stop, :normal, state}
  end
end
