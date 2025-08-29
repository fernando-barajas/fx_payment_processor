module WalletServices
  class FundService < BaseWalletService
    def call
      validate_attributes

      wallet_balance = wallet.balance_for(currency: @currency)
      wallet_balance.amount = wallet_balance.amount.to_d + amount.to_d

      create_transaction if wallet_balance.save!
    end

    private

    def validate_attributes
      validate_wallet
      validate_amount
      validate_currency
    end

    def validate_amount
      raise ArgumentError, "Amount must be non-negative" if amount.negative?
    end

    def create_transaction
      wallet.fund_transactions.create!(
        amount: amount,
        currency: currency
      )
    end
  end
end