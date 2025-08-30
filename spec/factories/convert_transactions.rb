FactoryBot.define do
  factory :convert_transaction do
    wallet { association(:wallet) }
    currency { "MXN" }
    to_currency { "USD" }
    amount { "9.99" }
    exchange_rate { 0.053 }
  end
end