module WalletServices
  class ConvertService < BaseWalletService
    USD_TO_MXN_EXCHANGE_RATE = 18.70
    MXN_TO_USD_EXCHANGE_RATE = 0.053

    def initialize(wallet:, amount:, from_currency:, to_currency:, custom_exchange_rate: nil)
      super(wallet: wallet, amount: amount, currency: from_currency)
      @to_currency = to_currency
      @custom_exchange_rate = custom_exchange_rate
    end

    def call
      validate_attributes

      ApplicationRecord.transaction do
        from_wallet_balance.amount = wallet_balance.amount.to_d - amount.to_d
        to_wallet_balance.amount = to_wallet_balance.amount.to_d + amount_to_fund

        from_wallet_balance.save!
        to_wallet_balance.save!

        create_transactions
      end
    end

    private

    attr_reader :to_currency, :custom_exchange_rate

    def validate_attributes
      validate_wallet
      validate_currencies
      validate_wallet_balance_for_currency
      validate_zero_amount
      validate_negative_amount
      validate_funds
      validate_exchange_rate
    end

    def validate_currencies
      if VALID_CURRENCIES.exclude?(currency) || VALID_CURRENCIES.exclude?(to_currency)
        raise ArgumentError, "Currency conversion not supported"
      end
    end

    def validate_exchange_rate
      if exchange_rate.to_f <= 0
        raise ArgumentError, "Invalid exchange rate"
      end
    end

    def from_wallet_balance
      @from_wallet_balance ||= wallet.balance_for(currency: currency).lock!
    end

    def to_wallet_balance
      @to_wallet_balance ||= wallet.balance_for(currency: to_currency).lock!
    end

    def amount_to_fund
      amount * exchange_rate
    end

    def exchange_rate
      @exchange_rate ||= fetch_exchange_rate
    end

    def fetch_exchange_rate
      return custom_exchange_rate.to_d if custom_exchange_rate.present?

      currency == "USD" ? USD_TO_MXN_EXCHANGE_RATE : MXN_TO_USD_EXCHANGE_RATE
    end

    def create_transactions
      create_fund_transaction
      create_withdraw_transaction
      create_convert_transaction
    end

    def create_fund_transaction
      wallet.fund_transactions.create!(
        amount: amount_to_fund,
        currency: to_currency
      )
    end

    def create_withdraw_transaction
      wallet.withdraw_transactions.create!(
        amount: amount,
        currency: currency
      )
    end

    def create_convert_transaction
      wallet.convert_transactions.create!(
        amount: amount,
        currency: currency,
        to_currency: to_currency,
        exchange_rate: exchange_rate
      )
    end
  end
end