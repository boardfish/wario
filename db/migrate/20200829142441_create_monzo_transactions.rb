class CreateMonzoTransactions < ActiveRecord::Migration[6.0]
  def change
    create_table :monzo_transactions do |t|
      t.jsonb :metadata

      t.timestamps
    end
  end
end
