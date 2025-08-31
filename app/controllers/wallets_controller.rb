class WalletsController < ApplicationController
  before_action :fetch_wallet

  rescue_from ActiveRecord::RecordNotFound do
    render json: { error: "Wallet not found" }, status: :not_found
  end

  def fund
    WalletServices::FundService.new(**transaction_params).call

    render json: { message: "Wallet funded successfully" }, status: :ok
  rescue ArgumentError => e
    render json: { error: e.message }, status: :unprocessable_entity
  end

  def withdraw
    WalletServices::WithdrawService.new(**transaction_params).call

    render json: { message: "Wallet withdrawn successfully" }, status: :ok
  rescue ArgumentError => e
    render json: { error: e.message }, status: :unprocessable_entity
  end

  def convert
    WalletServices::ConvertService.new(**convert_params).call

    render json: { message: "Funds converted successfully" }, status: :ok
  rescue ArgumentError => e
    render json: { error: e.message }, status: :unprocessable_entity
  end

  def balances
    wallet_balance = @wallet.current_balance

    if wallet_balance.present?
      render json: @wallet.current_balance, status: :ok
    else
      render json: { message: "Wallet with no balances" }, status: :ok
    end
  end

  def transactions
    render json: {
      fund_transactions: @wallet.fund_transactions_to_h,
      withdraw_transactions: @wallet.withdraw_transactions_to_h,
      convert_transactions: @wallet.convert_transactions_to_h
    }, status: :ok
  end

  def reconciliation_check
    reconciliation_check = WalletServices::ReconciliationCheckService.new(wallet: @wallet).call

    render json: reconciliation_check, status: :ok
  end

  private

  def fetch_wallet
    @wallet = Wallet.find_by!(user_id: params[:user_id])
  end

  def transaction_params
    params.permit(:amount, :currency)
    .with_defaults(wallet: @wallet)
    .to_h
    .symbolize_keys
  end

  def convert_params
    params.permit(:from_currency, :to_currency, :amount, :custom_exchange_rate)
    .with_defaults(wallet: @wallet)
    .to_h
    .symbolize_keys
  end
end