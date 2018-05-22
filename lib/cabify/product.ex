defmodule Cabify.Product do
  defstruct [
    :code,
    :name,
    :price,
    rule: %Cabify.Rule{}
  ]

  def new(product, rule) do
    %__MODULE__{
      code: product[:code],
      name: product[:name],
      price: product[:price] * 100,
      rule: rule
    }
  end

  def calc({product, qty_in_cart}) do
    {total, _} =
      product.rule.formula
      |> Code.eval_string(product: product, qty: qty_in_cart)

    total
  end
end
