class AddIndexToJoinTable < ActiveRecord::Migration
  def change
  	add_index :posts_users, [ :post_id, :user_id ], :unique => true, :name => 'by_user_and_post'
  end
end
