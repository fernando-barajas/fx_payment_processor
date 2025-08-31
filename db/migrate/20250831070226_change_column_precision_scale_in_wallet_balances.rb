class ChangeColumnPrecisionScaleInWalletBalances < ActiveRecord::Migration[7.2]
  def up
    change_column :wallet_balances, :amount, :decimal, precision: 20, scale: 3
  end

  def down
    change_column :wallet_balances, :amount, :decimal, precision: 10, scale: 2
  end
end
