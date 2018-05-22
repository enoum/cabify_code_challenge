defmodule Cabify.ProductTest do
  use ExUnit.Case

  alias Cabify.{
    Product,
    Rule
  }

  setup do
    p = %Product{
      code: "VOUCHER",
      name: "Cabify Voucher",
      price: 500,
      rule: %Rule{
        discount: 1,
        qty: 1,
        formula: "qty * product.price"
      }
    }

    %{product: p}
  end

  test "add a new product and return price in cents", %{product: product} do
    np = [code: "VOUCHER", name: "Cabify Voucher", price: 5.00]
    rule = Rule.new([1, 1, "qty * product.price"])

    assert product == Product.new(np, rule)
  end

  test "calculate price with no discount", %{product: product} do
    assert 1500 == Product.calc({product, 3})
  end

  test "calculate price with 2-for-1 discount", %{product: product} do
    product = %{product | rule: %{product.rule | discount: 0.5, qty: 2}}

    product = %{
      product
      | rule: %{
          product.rule
          | formula:
              "qty * product.price * product.rule.discount + (rem(qty, product.rule.qty) * product.price) * product.rule.discount"
        }
    }

    assert 1000 == Product.calc({product, 3})
  end

  test "calculate price for more than 3 discount", %{product: product} do
    product = %{product | price: 2000}
    product = %{product | rule: %{product.rule | discount: 0.95, qty: 3}}

    product = %{
      product
      | rule: %{
          product.rule
          | formula:
              "if (qty < product.rule.qty), do: qty * product.price, else: qty * product.price * product.rule.discount"
        }
    }

    assert 5700 == Product.calc({product, 3})
  end
end
