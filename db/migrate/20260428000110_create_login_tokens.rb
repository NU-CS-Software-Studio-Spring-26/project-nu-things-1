class CreateLoginTokens < ActiveRecord::Migration[8.1]
  def change
    create_table :login_tokens do |t|
      t.references :user, null: false, foreign_key: true
      t.datetime :expires_at, null: false
      t.datetime :used_at

      t.timestamps
    end

    add_index :login_tokens, :expires_at
  end
end

