class AddPasswordDigestToUsersIfMissing < ActiveRecord::Migration[8.1]
  def up
    return if column_exists?(:users, :password_digest)

    add_column :users, :password_digest, :string

    require "bcrypt"
    digest = BCrypt::Password.create("password", cost: BCrypt::Engine::MIN_COST)
    execute ActiveRecord::Base.sanitize_sql_array([
      "UPDATE users SET password_digest = ? WHERE password_digest IS NULL",
      digest
    ])

    change_column_null :users, :password_digest, false
  end

  def down
    remove_column :users, :password_digest if column_exists?(:users, :password_digest)
  end
end
