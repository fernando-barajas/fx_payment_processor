module WalletServices
  class BaseWalletService
    VALID_CURRENCIES = ["USD", "MXN"].freeze

    def initialize(wallet:, amount:, currency:)
      @wallet = wallet
      @amount = amount
      @currency = currency
    end

    private

    attr_reader :wallet, :amount, :currency

    def validate_wallet
      raise ArgumentError, "Wallet must be present" if wallet.nil?
    end

    def validate_currency
      raise ArgumentError, "Invalid currency" if VALID_CURRENCIES.exclude?(currency.upcase)
    end
  end
end
