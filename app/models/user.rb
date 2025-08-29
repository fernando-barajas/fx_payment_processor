class User < ApplicationRecord
  has_one :wallet, dependent: :destroy

  after_create :ensure_wallet!

  private

  def ensure_wallet!
    create_wallet! unless wallet.present?
  end
end
