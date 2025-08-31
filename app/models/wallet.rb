class Wallet < ApplicationRecord
  belongs_to :user
  has_many :wallet_balances, dependent: :destroy
  has_many :fund_transactions, dependent: :destroy
  has_many :withdraw_transactions, dependent: :destroy
  has_many :convert_transactions, dependent: :destroy

  def balance_for(currency:)
    wallet_balances.find_or_initialize_by(currency: currency.upcase)
  end

  def current_balance
    wallet_balances.inject({}) do |acc, balance|
      acc[balance.currency] = balance.amount.to_f
      acc
    end
  end

  def fund_transactions_to_h
    fund_transactions.map do |transaction|
      {
        amount: transaction.amount.to_f,
        currency: transaction.currency,
        created_at: transaction.created_at.strftime("%Y-%m-%d %H:%M:%S")
      }
    end
  end

  def withdraw_transactions_to_h
    withdraw_transactions.map do |transaction|
      {
        amount: transaction.amount.to_f,
        currency: transaction.currency,
        created_at: transaction.created_at.strftime("%Y-%m-%d %H:%M:%S")
      }
    end
  end

  def convert_transactions_to_h
    convert_transactions.map do |transaction|
      {
        amount: transaction.amount.to_f,
        from_currency: transaction.currency,
        to_currency: transaction.to_currency,
        created_at: transaction.created_at.strftime("%Y-%m-%d %H:%M:%S")
      }
    end
  end
end
