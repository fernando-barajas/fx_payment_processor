module WalletServices
  class ReconciliationCheckService
    def initialize(wallet:)
      @wallet = wallet
    end

    def call
      wallet.current_balance.each_with_object({}) do |(currency, balance), result|
        expected_balance = calculate_expected_balance(currency)
        result[currency] = balance == expected_balance ? "OK" : "Mismatch"
      end
    end

    private

    attr_reader :wallet

    def calculate_expected_balance(currency)
      total_amount = (total_amount_funded_for(currency:) + total_amount_funded_by_conversion_for(currency:)) -
                      (total_amount_withdrew_for(currency:) + total_amount_withdrew_by_conversion_for(currency:))
    end


    def total_amount_funded_for(currency:)
      wallet.fund_transactions.for_currency(currency).sum(:amount)
    end

    def total_amount_funded_by_conversion_for(currency:)
      wallet.convert_transactions.to_currency(currency).sum do |transaction|
        transaction.amount.to_f * transaction.exchange_rate
      end
    end

    def total_amount_withdrew_for(currency:)
      wallet.withdraw_transactions.for_currency(currency).sum(:amount)
    end

    def total_amount_withdrew_by_conversion_for(currency:)
      wallet.convert_transactions.from_currency(currency).sum(:amount)
    end
  end
end