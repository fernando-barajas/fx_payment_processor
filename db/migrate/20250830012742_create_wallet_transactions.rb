class CreateWalletTransactions < ActiveRecord::Migration[7.2]
  def change
    create_table :wallet_transactions do |t|
      t.references :wallet, null: false, foreign_key: true
      t.string :type
      t.string :currency
      t.string :to_currency
      t.decimal :amount, precision: 10, scale: 2
      t.decimal :exchange_rate, precision: 10, scale: 2

      t.timestamps
    end
  end
end
