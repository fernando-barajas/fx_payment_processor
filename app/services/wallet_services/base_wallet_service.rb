module WalletServices
  class BaseWalletService
    VALID_CURRENCIES = ["USD", "MXN"].freeze

    def initialize(wallet:, amount:, currency:)
      @wallet = wallet
      @amount = amount.to_d
      @currency = currency.to_s.upcase
    end

    private

    attr_reader :wallet, :amount, :currency

    def wallet_balance
      @wallet_balance ||= wallet.balance_for(currency: currency)
    end

    def create_withdraw_transaction
      wallet.withdraw_transactions.create!(
        amount: amount,
        currency: currency
      )
    end

    def create_fund_transaction
      wallet.fund_transactions.create!(
        amount: amount,
        currency: currency
      )
    end

    def validate_zero_amount
      raise ArgumentError, "Amount must be greater than 0" if amount.zero?
    end

    def validate_negative_amount
      raise ArgumentError, "Amount must be non-negative" if amount.negative?
    end

    def validate_wallet
      raise ArgumentError, "Wallet must be present" if wallet.nil?
    end

    def validate_currency
      raise ArgumentError, "Invalid currency" if VALID_CURRENCIES.exclude?(currency)
    end

    def validate_wallet_balance_for_currency
      unless wallet_balance.persisted?
        raise ArgumentError, "The user doesn't have a wallet balance for the specified currency"
      end
    end

    def validate_funds
      raise ArgumentError, "Insufficient funds" if wallet_balance.amount < amount
    end
  end
end
