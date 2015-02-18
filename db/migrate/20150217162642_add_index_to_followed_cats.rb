class AddIndexToFollowedCats < ActiveRecord::Migration
  def change
  	add_index :follower_relations, :cat_id
  	
  end
end
