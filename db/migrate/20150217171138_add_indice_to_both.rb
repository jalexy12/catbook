class AddIndiceToBoth < ActiveRecord::Migration
  def change
  	add_index :follower_relations, [:cat_id, :followed_cat_id]
  end
end
