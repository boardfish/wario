class CreateMonzoTransactions < ActiveRecord::Migration[6.0]
  def change
    create_table :monzo_transactions do |t|
      t.jsonb :metadata, null: false, default:  {}

      t.timestamps
    end
    add_index  :monzo_transactions, :metadata, using: :gin
  end
end
