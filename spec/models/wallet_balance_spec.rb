require 'rails_helper'

RSpec.describe WalletBalance, type: :model do
  let(:wallet) { FactoryBot.create(:wallet) }
  let(:wallet_balance) { FactoryBot.create(:wallet_balance, wallet: wallet) }

  it "the balance can not be negative" do
    wallet_balance.amount = -10

    expect(wallet_balance).not_to be_valid
  end
end
