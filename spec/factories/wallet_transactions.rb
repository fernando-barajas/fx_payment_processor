FactoryBot.define do
  factory :wallet_transaction do
    wallet { nil }
    kind { "MyString" }
    currency { "MyString" }
    amount { "9.99" }
  end
end
