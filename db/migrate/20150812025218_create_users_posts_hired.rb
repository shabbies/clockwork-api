class CreateUsersPostsHired < ActiveRecord::Migration
  def self.up
    create_table 'posts_users_hired', :id => false do |t|
    	t.column 'post_id', :integer
    	t.column 'user_id', :integer 
    end  
  	add_index 'posts_users_hired', [ :post_id, :user_id ], :unique => true, :name => 'by_user_and_post_hired'
  end

  def self.down
  	drop_table 'posts_users_hired'
  end
end
