class CreateWalletBalances < ActiveRecord::Migration[7.2]
  def change
    create_table :wallet_balances do |t|
      t.references :wallet, null: false, foreign_key: true
      t.string :currency, null: false
      t.decimal :amount, precision: 10, scale: 2

      t.timestamps
    end
  end
end
