module InvestmentsHelper
  def nice_money(amount)
    number_to_currency(amount, unit: "$", separator: "_", precision: 0)
  end
end
