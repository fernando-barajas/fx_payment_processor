require "rails_helper"

RSpec.describe WalletServices::FundService do
  let(:user) { FactoryBot.create(:user) }
  let(:wallet) { user.wallet }

  context "when the wallet balance for the currency used does not exist" do
    it "creates the wallet balance for the currency and save the amount" do
      expect {
        WalletServices::FundService.new(wallet: wallet, amount: 100, currency: "USD").call
      }.to change { wallet.wallet_balances.count}.by(1)

      wallet.reload
      expect(wallet.balance_for(currency: "USD").amount).to eq(100)
    end

    it 'creates a wallet balance for the new currency' do
      FactoryBot.create(:wallet_balance, wallet: wallet, currency: "USD", amount: 100)

      expect {
        WalletServices::FundService.new(wallet: wallet, amount: 180, currency: "MXN").call
      }.to change { wallet.wallet_balances.count }.by(1)

      wallet.reload
      expect(wallet.balance_for(currency: "MXN").amount).to eq(180)
    end

    it "creates a wallet transaction" do
      expect {
        WalletServices::FundService.new(wallet: wallet, amount: 100, currency: "USD").call
      }.to change { wallet.fund_transactions.count}.by(1)
    end
  end

  context "when the wallet balance for the currency exists" do
    it "doesn't create a new wallet balance" do
      FactoryBot.create(:wallet_balance, wallet: wallet, currency: "USD", amount: 100)

      expect {
        WalletServices::FundService.new(wallet: wallet, amount: 50.5, currency: "USD").call
      }.not_to change { wallet.wallet_balances.count }

      wallet.reload
      expect(wallet.balance_for(currency: "USD").amount).to eq(150.5)
    end

    it "creates a wallet transaction" do
      expect {
        WalletServices::FundService.new(wallet: wallet, amount: 100, currency: "USD").call
      }.to change { wallet.fund_transactions.count}.by(1)
    end
  end

  context "Try to fund the wallet with invalid params" do
    context "when the amount is negative" do
      it "doesn't update the wallet balance" do
        FactoryBot.create(:wallet_balance, wallet: wallet, currency: "USD", amount: 100)

        expect {
          WalletServices::FundService.new(wallet: wallet, amount: -50, currency: "USD").call
        }.to raise_error(ArgumentError, "Amount must be non-negative")
      end

      it "doesn't creates a wallet transaction" do
        expect {
          WalletServices::FundService.new(wallet: wallet, amount: -100, currency: "USD").call
        }.to raise_error(ArgumentError, "Amount must be non-negative")
        .and change { wallet.fund_transactions.count }.by(0)
      end
    end

    context "when amount is zero" do
      it "doesn't update the wallet balance" do
        FactoryBot.create(:wallet_balance, wallet: wallet, currency: "USD", amount: 0)

        expect {
          WalletServices::FundService.new(wallet: wallet, amount: 0, currency: "USD").call
        }.to raise_error(ArgumentError, "Amount must be greater than 0")
      end

      it "doesn't creates a wallet transaction" do
        expect {
          WalletServices::FundService.new(wallet: wallet, amount: 0, currency: "USD").call
        }.to raise_error(ArgumentError, "Amount must be greater than 0")
        .and change { wallet.fund_transactions.count }.by(0)
      end
    end

    context "when the currency is not valid" do
      it "raises an error" do
        expect {
          WalletServices::FundService.new(wallet: wallet, amount: 100, currency: "EUR").call
        }.to raise_error(ArgumentError, "Invalid currency")
      end

      it "doesn't creates a wallet transaction" do
        expect {
          WalletServices::FundService.new(wallet: wallet, amount: 100, currency: "EUR").call
        }.to raise_error(ArgumentError, "Invalid currency")
        .and change { wallet.fund_transactions.count }.by(0)
      end
    end

    context "when the wallet is not present" do
      it "raises an error" do
        expect {
          WalletServices::FundService.new(wallet: nil, amount: 100, currency: "USD").call
        }.to raise_error(ArgumentError, "Wallet must be present")
      end

      it "doesn't creates a wallet transaction" do
        expect {
          WalletServices::FundService.new(wallet: nil, amount: 100, currency: "USD").call
        }.to raise_error(ArgumentError, "Wallet must be present")
        .and change { wallet.fund_transactions.count }.by(0)
      end
    end
  end
end
