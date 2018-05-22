defmodule Cabify.Rule do
  defstruct [
    :qty,
    :discount,
    :formula
  ]

  def new(rule) do
    %__MODULE__{
      qty: Enum.at(rule, 0),
      discount: Enum.at(rule, 1),
      formula: Enum.at(rule, 2)
    }
  end
end
