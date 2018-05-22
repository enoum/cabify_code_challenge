defmodule Cabify.CheckoutTest do
  use ExUnit.Case, async: false

  alias Cabify.{
    Checkout,
    Product,
    Rule
  }

  setup do
    on_exit(fn ->
      Checkout |> Process.whereis() |> send(:bye)
    end)
  end

  test "add returns the right qty for each product" do
    assert 1 == Checkout.scan("VOUCHER")
    assert 1 == Checkout.scan("TSHIRT")
    assert 2 == Checkout.scan("VOUCHER")
  end

  test "return a list of all products in cart" do
    Checkout.scan("VOUCHER")
    Checkout.scan("TSHIRT")
    Checkout.scan("VOUCHER")

    assert [{"VOUCHER", 2}, {"TSHIRT", 1}] == Checkout.all()
  end

  test "retrun total" do
    product = [code: "VOUCHER", name: "Cabify Voucher", price: 5.00]

    rule =
      Rule.new([
        2,
        0.5,
        "qty * product.price * product.rule.discount + (rem(qty, product.rule.qty) * product.price) * product.rule.discount"
      ])

    voucher = Product.new(product, rule)

    product = [code: "TSHIRT", name: "Cabify T-Shirt", price: 20.00]

    rule =
      Rule.new([
        3,
        0.95,
        "if (qty < product.rule.qty), do: qty * product.price, else: qty * product.price * product.rule.discount"
      ])

    tshirt = Product.new(product, rule)

    product = [code: "MUG", name: "Cabify Mug", price: 7.50]
    rule = Rule.new([1, 1, "qty * product.price"])
    mug = Product.new(product, rule)

    Checkout.scan(voucher)
    Checkout.scan(tshirt)
    Checkout.scan(voucher)
    Checkout.scan(voucher)
    Checkout.scan(mug)
    Checkout.scan(tshirt)
    Checkout.scan(tshirt)

    assert 74.50 == Checkout.total()
  end
end
