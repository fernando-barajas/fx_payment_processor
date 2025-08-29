class WalletBalance < ApplicationRecord
  belongs_to :wallet

  validates :currency, presence: true
  validates :amount, presence: true, numericality: { greater_than_or_equal_to: 0 }
end
