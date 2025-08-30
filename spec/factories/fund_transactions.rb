FactoryBot.define do
  factory :fund_transaction do
    wallet { association(:wallet) }
    currency { "USD" }
    amount { "9.99" }
  end
end