class FundTransaction < WalletTransaction
  scope :for_currency, ->(currency) { where(currency: currency.upcase) }
end
