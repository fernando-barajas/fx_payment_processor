module WalletServices
  class BaseWalletService
    VALID_CURRENCIES = ["USD", "MXN"].freeze

    def initialize(wallet:, amount:, currency:)
      @wallet = wallet
      @amount = amount.to_d
      @currency = currency
    end

    private

    attr_reader :wallet, :amount, :currency

    def wallet_balance
      @wallet_balance ||= wallet.balance_for(currency: currency.upcase)
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
      raise ArgumentError, "Invalid currency" if VALID_CURRENCIES.exclude?(currency.to_s.upcase)
    end
  end
end
