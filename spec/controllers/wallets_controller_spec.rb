require 'rails_helper'

RSpec.describe WalletsController, type: :controller do
  describe "POST #fund" do
    let(:user) { FactoryBot.create(:user) }
    let(:wallet) { user.wallet}

    it "returns a success response" do
      post :fund, params: { user_id: user.id, amount: 100, currency: "USD" }

      expect(response).to be_successful
      fund_transaction = wallet.reload.fund_transactions.last

      expect(fund_transaction.amount).to eq(100)
      expect(fund_transaction.currency).to eq("USD")
    end

    context "when the wallet doesn't exist" do
      it "returns a not found response" do
        post :fund, params: { user_id: 999, amount: 100, currency: "USD" }

        parsed_body = JSON.parse(response.body)

        expect(response).to have_http_status(:not_found)
        expect(parsed_body["error"]).to eq("Wallet not found")
      end
    end

    context "with invalid parameters" do
      it "returns an error response invalid amount" do
        post :fund, params: { user_id: user.id, amount: nil, currency: "USD" }

        parsed_body = JSON.parse(response.body)

        expect(response).to have_http_status(:unprocessable_entity)
        expect(parsed_body["error"]).to eq("Amount must be greater than 0")
      end

      it "returns an error response invalid currency" do
        post :fund, params: { user_id: user.id, amount: 100, currency: "EUR" }

        parsed_body = JSON.parse(response.body)

        expect(response).to have_http_status(:unprocessable_entity)
        expect(parsed_body["error"]).to eq("Invalid currency")
      end

      it "returns an error response when amount is 0" do
        post :fund, params: { user_id: user.id, amount: 0, currency: "USD" }

        parsed_body = JSON.parse(response.body)

        expect(response).to have_http_status(:unprocessable_entity)
        expect(parsed_body["error"]).to eq("Amount must be greater than 0")
      end
    end
  end

  describe "POST #withdraw" do
    let(:user) { FactoryBot.create(:user) }
    let(:wallet) { user.wallet}

    it "returns a success response" do
      FactoryBot.create(:wallet_balance, wallet:, currency: "USD", amount: 200)

      post :withdraw, params: { user_id: user.id, amount: 50, currency: "USD" }

      expect(response).to be_successful

      withdraw_transaction = wallet.reload.withdraw_transactions.last

      expect(withdraw_transaction.amount).to eq(50)
      expect(withdraw_transaction.currency).to eq("USD")
    end

    context "when the wallet doesn't exist" do
      it "returns a not found response" do
        FactoryBot.create(:wallet_balance, wallet:, currency: "USD", amount: 20)

        post :withdraw, params: { user_id: 999, amount: 50, currency: "USD" }

        parsed_body = JSON.parse(response.body)

        expect(response).to have_http_status(:not_found)
        expect(parsed_body["error"]).to eq("Wallet not found")
      end
    end

    context "with invalid parameters" do
      let!(:wallet_balance) { FactoryBot.create(:wallet_balance, wallet:, currency: "USD", amount: 20) }

      it "returns an error response invalid amount" do
        post :withdraw, params: { user_id: user.id, amount: nil, currency: "USD" }

        parsed_body = JSON.parse(response.body)

        expect(response).to have_http_status(:unprocessable_entity)
        expect(parsed_body["error"]).to eq("Amount must be greater than 0")
      end

      it "returns an error response invalid currency" do
        post :withdraw, params: { user_id: user.id, amount: 50, currency: "EUR" }

        parsed_body = JSON.parse(response.body)

        expect(response).to have_http_status(:unprocessable_entity)
        expect(parsed_body["error"]).to eq("Invalid currency")
      end

      it "returns an error response when amount is 0" do
        post :withdraw, params: { user_id: user.id, amount: 0, currency: "USD" }

        parsed_body = JSON.parse(response.body)

        expect(response).to have_http_status(:unprocessable_entity)
        expect(parsed_body["error"]).to eq("Amount must be greater than 0")
      end
    end
  end

  describe "POST #convert" do
    let(:user) { FactoryBot.create(:user) }
    let(:wallet) { user.wallet }

    context "when there's enough balance" do
      it "converts the currency successfully" do
        FactoryBot.create(:wallet_balance, wallet:, currency: "USD", amount: 100)

        post :convert, params: { user_id: user.id, from_currency: "USD", to_currency: "MXN", amount: 50 }

        expect(response).to be_successful
      end
    end

    context "when there's not enough balance" do
      it "returns an error response" do
        FactoryBot.create(:wallet_balance, wallet:, currency: "USD", amount: 30)

        post :convert, params: { user_id: user.id, from_currency: "USD", to_currency: "MXN", amount: 50 }

        parsed_body = JSON.parse(response.body)

        expect(response).to have_http_status(:unprocessable_entity)
        expect(parsed_body["error"]).to eq("Insufficient funds")
      end
    end

    context "when trying to convert between currencies that are not supported" do
      it "returns an error response" do
        FactoryBot.create(:wallet_balance, wallet:, currency: "USD", amount: 100)

        post :convert, params: { user_id: user.id, from_currency: "USD", to_currency: "EUR", amount: 50 }

        parsed_body = JSON.parse(response.body)

        expect(response).to have_http_status(:unprocessable_entity)
        expect(parsed_body["error"]).to eq("Currency conversion not supported")
      end
    end
  end

  describe "GET #balances" do
    let(:user) { FactoryBot.create(:user) }
    let(:wallet) { user.wallet }

    it "returns the wallet balances" do
      FactoryBot.create(:wallet_balance, wallet:, currency: "USD", amount: 100)
      FactoryBot.create(:wallet_balance, wallet:, currency: "MXN", amount: 200)

      get :balances, params: { user_id: user.id }

      expect(response).to be_successful
      expect(JSON.parse(response.body)).to eq(
        "USD" => 100.0,
        "MXN" => 200.0
      )
    end

    it "returns the correct balance after some transactions" do
      FactoryBot.create(:wallet_balance, wallet:, currency: "USD", amount: 100)
      FactoryBot.create(:wallet_balance, wallet:, currency: "MXN", amount: 200)

      post :withdraw, params: { user_id: user.id, amount: 50, currency: "USD" }
      post :fund, params: { user_id: user.id, amount: 48.95, currency: "MXN" }
      post :convert, params: { user_id: user.id, from_currency: "MXN", to_currency: "USD", amount: 100 }
      post :convert, params: { user_id: user.id, from_currency: "USD", to_currency: "MXN", amount: 20, custom_exchange_rate: 21 }

      get :balances, params: { user_id: user.id }

      expect(response).to be_successful
      expect(JSON.parse(response.body)).to eq(
        "USD" => 35.3,
        "MXN" => 568.95
      )
    end

    it "returns empty balances message when no funds are available" do
      get :balances, params: { user_id: user.id }

      expect(response).to be_successful
      parsed_body = JSON.parse(response.body)
      expect(parsed_body["message"]).to eq("Wallet with no balances")
    end
  end

  describe "GET #transactions" do
    let(:user) { FactoryBot.create(:user) }
    let(:wallet) { user.wallet }

    it "returns the wallet transactions" do
      fund = FactoryBot.create(:fund_transaction, wallet:, amount: 100, currency: "USD")
      withdraw = FactoryBot.create(:withdraw_transaction, wallet:, amount: 50, currency: "MXN")
      convert = FactoryBot.create(:convert_transaction, wallet:, amount: 25, currency: "USD", to_currency: "MXN")

      get :transactions, params: { user_id: user.id }

      expect(response).to be_successful

      parsed_body = JSON.parse(response.body)

      expect(parsed_body).to eq(
        "fund_transactions" => [
          { "amount" => 100.0, "currency" => "USD", "created_at" => fund.created_at.strftime("%Y-%m-%d %H:%M:%S") }
        ],
        "withdraw_transactions" => [
          { "amount" => 50.0, "currency" => "MXN", "created_at" => withdraw.created_at.strftime("%Y-%m-%d %H:%M:%S") }
        ],
        "convert_transactions" => [
          { "amount" => 25.0, "from_currency" => "USD", "to_currency" => "MXN",
            "created_at" => convert.created_at.strftime("%Y-%m-%d %H:%M:%S") }
        ]
      )
    end
  end
end
