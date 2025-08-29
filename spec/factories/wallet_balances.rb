FactoryBot.define do
  factory :wallet_balance do
    wallet { nil }
    currency { "USD" }
    amount { "9.99" }
  end
end
