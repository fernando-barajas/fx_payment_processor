FactoryBot.define do
  factory :withdraw_transaction do
    wallet { association(:wallet) }
    currency { "MXN" }
    amount { "9.99" }
  end
end