class AddUniqueEmailIndexToCats < ActiveRecord::Migration
  def change
  	add_index :cats, :email, :unique => true
  end
end
