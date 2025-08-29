require 'rails_helper'

RSpec.describe WalletBalance, type: :model do
  let(:user) { FactoryBot.create(:user) }
  let(:wallet) { user.wallet }
  let(:wallet_balance) { FactoryBot.create(:wallet_balance, wallet: wallet) }

  it "the balance can not be negative" do
    wallet_balance.amount = -10

    expect(wallet_balance).not_to be_valid
  end

  it 'is valid if amount is positive' do
    wallet_balance.amount = 100
    expect(wallet_balance).to be_valid
  end

  it 'is valid if amount is zero' do
    wallet_balance.amount = 0
    expect(wallet_balance).to be_valid
  end
end
