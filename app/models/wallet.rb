class Wallet < ApplicationRecord
  belongs_to :user
  has_many :wallet_balances, dependent: :destroy
  has_many :fund_transactions, dependent: :destroy
  has_many :withdraw_transactions, dependent: :destroy
  has_many :convert_transactions, dependent: :destroy

  def balance_for(currency:)
    wallet_balances.find_or_initialize_by(currency: currency.upcase)
  end

  def reconciliation_check
    current_balance.each_with_object({}) do |(currency, balance), acc|
      total_amount = (total_amount_funded_for(currency:) + total_amount_funded_by_conversion_for(currency:)) -
                      (total_amount_withdrew_for(currency:) + total_amount_withdrew_by_conversion_for(currency:))

      acc[currency] = total_amount.to_d == balance ? "OK" : "Mismatch"
    end
  end

  def total_amount_funded_for(currency:)
    fund_transactions.for_currency(currency).sum(:amount)
  end

  def total_amount_funded_by_conversion_for(currency:)
    convert_transactions.to_currency(currency).sum do |transaction|
      transaction.amount.to_f * transaction.exchange_rate
    end
  end

  def total_amount_withdrew_for(currency:)
    withdraw_transactions.for_currency(currency).sum(:amount)
  end

  def total_amount_withdrew_by_conversion_for(currency:)
    convert_transactions.from_currency(currency).sum(:amount)
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
