FactoryBot.define do
  factory :wallet_balance do
    wallet { nil }
    currency { "USD" }
    amount { 0 }
  end
end