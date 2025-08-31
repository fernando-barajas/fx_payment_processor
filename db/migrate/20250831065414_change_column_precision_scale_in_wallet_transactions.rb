class ChangeColumnPrecisionScaleInWalletTransactions < ActiveRecord::Migration[7.2]
  def up
    change_column :wallet_transactions, :exchange_rate, :decimal, precision: 20, scale: 3
    change_column :wallet_transactions, :amount, :decimal, precision: 20, scale: 3
  end

  def down
    change_column :wallet_transactions, :exchange_rate, :decimal, precision: 10, scale: 2
    change_column :wallet_transactions, :amount, :decimal, precision: 10, scale: 2
  end
end
