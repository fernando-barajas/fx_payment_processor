require "rails_helper"

RSpec.describe WalletServices::ReconciliationCheckService do
  let(:user) { FactoryBot.create(:user) }
  let(:wallet) { user.wallet }

  subject { described_class.new(wallet: wallet) }

  describe "#call" do
    context "when there are no discrepancies" do
      it "returns a hash with each currency with OK status" do
        WalletServices::FundService.new(wallet: wallet, amount: 100, currency: "USD").call
        WalletServices::FundService.new(wallet: wallet, amount: 100, currency: "MXN").call
        WalletServices::WithdrawService.new(wallet: wallet, amount: 50, currency: "USD").call
        WalletServices::ConvertService.new(wallet: wallet, amount: 20, from_currency: "USD", to_currency: "MXN", custom_exchange_rate: 21).call

        discrepancies = subject.call

        expect(discrepancies).to be_a(Hash)
        expect(discrepancies).to include("USD" => "OK", "MXN" => "OK")
      end
    end

    context "when there are discrepancies" do
      it "returns a hash with each currency and its discrepancy status" do
        WalletServices::FundService.new(wallet: wallet, amount: 100, currency: "USD").call
        WalletServices::FundService.new(wallet: wallet, amount: 100, currency: "MXN").call

        mxn_balance = wallet.balance_for(currency: "MXN")
        mxn_balance.update!(amount: mxn_balance.amount - 10) # Introduce a discrepancy


        discrepancies = subject.call

        expect(discrepancies).to be_a(Hash)
        expect(discrepancies).to include("USD" => "OK", "MXN" => "Mismatch")
      end
    end
  end
end
