class CreateUsersPostsJoin < ActiveRecord::Migration
  def self.up
    create_table 'posts_users', :id => false do |t|
    	t.column 'post_id', :integer
    	t.column 'user_id', :integer 
    end
  end

  def self.down
  	drop_table 'posts_users'
  end
end
