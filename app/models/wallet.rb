class Wallet < ApplicationRecord
  belongs_to :user
  has_many :wallet_balances, dependent: :destroy
  has_many :fund_transactions, dependent: :destroy

  def balance_for(currency:)
    wallet_balances.find_or_initialize_by(currency: currency.upcase)
  end
end
