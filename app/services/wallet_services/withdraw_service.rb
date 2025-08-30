module WalletServices
  class WithdrawService < BaseWalletService
    def call
      validate_attributes

      wallet_balance.with_lock do
        wallet_balance.amount = wallet_balance.amount.to_d - amount.to_d

        create_transaction if wallet_balance.save!
      end
    end

    private

    def validate_attributes
      validate_wallet
      validate_currency
      validate_wallet_balance_for_currency
      validate_zero_amount
      validate_negative_amount
      validate_funds
    end

    def create_transaction
      wallet.withdraw_transactions.create!(
        amount: amount,
        currency: currency
      )
    end
  end
end