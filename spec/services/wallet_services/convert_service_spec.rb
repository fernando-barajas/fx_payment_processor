require "rails_helper"

RSpec.describe WalletServices::ConvertService do
  let(:user) { FactoryBot.create(:user) }
  let(:wallet) { user.wallet }

  subject do
    described_class.new(wallet: wallet, amount: amount, from_currency: from_currency, to_currency: to_currency)
  end

  context "when there's enough balance in the source" do
    let(:amount) { 100 }
    let!(:wallet_balance_usd) { FactoryBot.create(:wallet_balance, wallet: wallet, currency: "USD", amount: 200) }
    let!(:wallet_balance_mxn) { FactoryBot.create(:wallet_balance, wallet: wallet, currency: "MXN", amount: 200) }

    context "from USD to MXN" do
      let(:from_currency) { "USD" }
      let(:to_currency) { "MXN" }

      it "converts the currency" do
        exchange_rate = 18.70
        funded_amount = amount.to_d * exchange_rate

        expect { subject.call }
        .to change { wallet.balance_for(currency: from_currency).amount }.by(-amount)
        .and change { wallet.balance_for(currency: to_currency).amount }.by(funded_amount)
        .and change { wallet.convert_transactions.count }.by(1)
        .and change { wallet.fund_transactions.count }.by(0)
        .and change { wallet.withdraw_transactions.count }.by(0)
      end

      it "creates the convert transactions with the correct attributes" do
        exchange_rate = 18.70
        funded_amount = amount.to_d * exchange_rate

        expect { subject.call }.to change { wallet.convert_transactions.count }.by(1)

        wallet.reload

        convert_transaction = wallet.convert_transactions.last

        expect(convert_transaction).to have_attributes(
          currency: "USD",
          amount: amount,
          to_currency: "MXN",
          exchange_rate: exchange_rate
        )
      end
    end

    context "from MXN to USD" do
      let(:from_currency) { "MXN" }
      let(:to_currency) { "USD" }

      it "converts the currency" do
        exchange_rate = 0.053
        funded_amount = amount.to_d * exchange_rate

        expect { subject.call }
        .to change { wallet.balance_for(currency: from_currency).amount }.by(-amount)
        .and change { wallet.balance_for(currency: to_currency).amount }.by(funded_amount)
      end
    end
  end

  context "passing custom exchange rate" do
    let(:amount) { 100 }
    let(:from_currency) { "USD" }
    let(:to_currency) { "MXN" }
    let!(:wallet_balance_usd) { FactoryBot.create(:wallet_balance, wallet: wallet, currency: "USD", amount: 200) }
    let!(:wallet_balance_mxn) { FactoryBot.create(:wallet_balance, wallet: wallet, currency: "MXN", amount: 200) }
    let(:custom_exchange_rate) { 20.053 }

    subject do
      described_class.new(wallet:, amount:, from_currency:, to_currency:, custom_exchange_rate:)
    end

    it "uses the custom exchange rate" do
      prev_amount = wallet.balance_for(currency: "MXN").amount

      subject.call

      new_amount = prev_amount + (amount.to_d * custom_exchange_rate)
      expect(wallet.balance_for(currency: "MXN").amount).to eq(new_amount)
      expect(wallet.convert_transactions.last).to have_attributes(
        currency: "USD",
        amount: amount,
        to_currency: "MXN",
        exchange_rate: custom_exchange_rate
      )
    end

    context "passing invalid exchange rate" do
      let(:custom_exchange_rate) { -1.0 }

      it "raises an error" do
        expect { subject.call }.to raise_error(ArgumentError, "Invalid exchange rate")
      end
    end
  end

  context "when there's not destination wallet balance" do
    let(:amount) { 100 }
    let(:from_currency) { "USD" }
    let(:to_currency) { "MXN" }
    let!(:wallet_balance_usd) { FactoryBot.create(:wallet_balance, wallet: wallet, currency: "USD", amount: 200) }

    it "creates the destination wallet balance" do
      exchange_rate = 18.70
      funded_amount = amount.to_d * exchange_rate

      expect { subject.call }.to change { wallet.wallet_balances.count }.by(1)
      expect(wallet.balance_for(currency: to_currency).amount).to eq(funded_amount)
    end
  end

  context "when there's not enough balance in the source" do
    let(:amount) { 300 }
    let(:from_currency) { "USD" }
    let(:to_currency) { "MXN" }
    let!(:wallet_balance_usd) { FactoryBot.create(:wallet_balance, wallet: wallet, currency: "USD", amount: 200) }
    let!(:wallet_balance_mxn) { FactoryBot.create(:wallet_balance, wallet: wallet, currency: "MXN", amount: 200) }

    it "does not convert the currency" do
      expect { subject.call }.to raise_error(ArgumentError, "Insufficient funds")
    end
  end

  context "with invalid params" do
    context "when wallet doesn't exist" do
      let(:wallet) { nil }
      let(:amount) { -100 }
      let(:from_currency) { "USD" }
      let(:to_currency) { "MXN" }

      it "raises an error" do
        expect { subject.call }.to raise_error(ArgumentError, "Wallet must be present")
      end
    end

    context "when the currency is not valid" do
      let(:amount) { 300 }
      let(:from_currency) { "EUR" }
      let(:to_currency) { "MXN" }

      it "raise an error" do
        expect { subject.call }.to raise_error(ArgumentError, "Currency conversion not supported")
      end
    end

    context "the source balance doesn't exist" do
      let(:amount) { 100 }
      let(:from_currency) { "USD" }
      let(:to_currency) { "MXN" }
      let!(:wallet_balance_mxn) { FactoryBot.create(:wallet_balance, wallet: wallet, currency: "MXN", amount: 200) }

      it "raises an error" do
        expect { subject.call }.to raise_error(ArgumentError, "The user doesn't have a wallet balance for the specified currency")
      end
    end

    context "when the amount is zero" do
      let(:amount) { 0 }
      let(:from_currency) { "USD" }
      let(:to_currency) { "MXN" }
      let!(:wallet_balance_usd) { FactoryBot.create(:wallet_balance, wallet: wallet, currency: "USD", amount: 200) }

      it "raises an error" do
        expect { subject.call }.to raise_error(ArgumentError, "Amount must be greater than 0")
      end
    end
  end
end
