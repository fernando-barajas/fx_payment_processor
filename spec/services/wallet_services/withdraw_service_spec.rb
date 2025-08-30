require "rails_helper"

RSpec.describe WalletServices::WithdrawService do
  let(:user) { FactoryBot.create(:user) }
  let(:wallet) { user.wallet }
  let!(:wallet_balance) { FactoryBot.create(:wallet_balance, wallet: wallet, currency: "USD", amount: 100) }

  context "when the wallet balance for the currency exists" do
    it "withdraw the amount from the wallet balance" do
      expect {
        WalletServices::WithdrawService.new(wallet: wallet, amount: 50, currency: "USD").call
      }.to change { wallet.balance_for(currency: "USD").amount }.by(-50)
      .and change { wallet.withdraw_transactions.count }.by(1)

      wallet.reload
      expect(wallet.balance_for(currency: "USD").amount).to eq(50)
    end

    it "doesn't allow withdrawal of more than the available balance" do
      expect {
        WalletServices::WithdrawService.new(wallet: wallet, amount: 150, currency: "USD").call
      }.to raise_error(ArgumentError, "Insufficient funds")
      .and change { wallet.withdraw_transactions.count }.by(0)
    end
  end

  context "Try to withdraw from a wallet balance that doesn't exist" do
    it "raise an error" do
      expect {
        WalletServices::WithdrawService.new(wallet: wallet, amount: 50, currency: "MXN").call
      }.to raise_error(ArgumentError, "The user doesn't have a wallet balance for the specified currency")
      .and change { wallet.withdraw_transactions.count }.by(0)
    end
  end

  context "Try to withdraw the wallet with invalid params" do
    context "when the amount is negative" do
      it "doesn't update the wallet balance" do
        FactoryBot.create(:wallet_balance, wallet: wallet, currency: "USD", amount: 100)

        expect {
          WalletServices::WithdrawService.new(wallet: wallet, amount: -50, currency: "USD").call
        }.to raise_error(ArgumentError, "Amount must be non-negative")
        .and change { wallet.withdraw_transactions.count }.by(0)
      end
    end

    context "when amount is zero" do
      it "doesn't update the wallet balance" do
        FactoryBot.create(:wallet_balance, wallet: wallet, currency: "USD", amount: 0)

        expect {
          WalletServices::WithdrawService.new(wallet: wallet, amount: 0, currency: "USD").call
        }.to raise_error(ArgumentError, "Amount must be greater than 0")
        .and change { wallet.withdraw_transactions.count }.by(0)
      end
    end

    context "when the currency is not valid" do
      it "raises an error" do
        expect {
          WalletServices::WithdrawService.new(wallet: wallet, amount: 100, currency: "EUR").call
        }.to raise_error(ArgumentError, "Invalid currency")
        .and change { wallet.withdraw_transactions.count }.by(0)
      end
    end

    context "when the wallet is not present" do
      it "raises an error" do
        expect {
          WalletServices::WithdrawService.new(wallet: nil, amount: 100, currency: "USD").call
        }.to raise_error(ArgumentError, "Wallet must be present")
        .and change { wallet.withdraw_transactions.count }.by(0)
      end
    end
  end
end
