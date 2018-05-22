defmodule Cabify do
  alias Cabify.{
    Checkout,
    Product,
    Rule
  }

  def main(_args) do
    {voucher, tshirt, mug} = define_products()

    IO.puts("Running tests...\n")

    IO.puts("Items: VOUCHER, TSHIRT, MUG")
    Checkout.scan(voucher)
    Checkout.scan(tshirt)
    Checkout.scan(mug)
    total = Checkout.total()
    Checkout |> Process.whereis() |> send(:bye)
    IO.puts("Total: #{total}€\n")

    IO.puts("Items: VOUCHER, TSHIRT, VOUCHER")
    Checkout.scan(voucher)
    Checkout.scan(tshirt)
    Checkout.scan(voucher)
    total = Checkout.total()
    Checkout |> Process.whereis() |> send(:bye)

    IO.puts("Total: #{total}€\n")

    IO.puts("Items: TSHIRT, TSHIRT, TSHIRT, VOUCHER, TSHIRT")
    Checkout.scan(tshirt)
    Checkout.scan(tshirt)
    Checkout.scan(tshirt)
    Checkout.scan(voucher)
    Checkout.scan(tshirt)
    total = Checkout.total()
    Checkout |> Process.whereis() |> send(:bye)

    IO.puts("Total: #{total}€\n")

    IO.puts("Items: VOUCHER, TSHIRT, VOUCHER, VOUCHER, MUG, TSHIRT, TSHIRT")
    Checkout.scan(voucher)
    Checkout.scan(tshirt)
    Checkout.scan(voucher)
    Checkout.scan(voucher)
    Checkout.scan(mug)
    Checkout.scan(tshirt)
    Checkout.scan(tshirt)
    total = Checkout.total()
    Checkout |> Process.whereis() |> send(:bye)

    IO.puts("Total: #{total}€\n")
  end

  defp define_products do
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

    {voucher, tshirt, mug}
  end
end
