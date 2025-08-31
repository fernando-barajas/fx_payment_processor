class ConvertTransaction < WalletTransaction
  scope :from_currency, ->(currency) { where(currency: currency.upcase) }
  scope :to_currency, ->(currency) { where(to_currency: currency.upcase) }
end
