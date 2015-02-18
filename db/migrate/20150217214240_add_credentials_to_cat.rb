class AddCredentialsToCat < ActiveRecord::Migration
  def change
    add_column :cats, :email, :string
    add_column :cats, :password_digest, :string
  end
end
