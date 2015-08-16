class DropPostUserHiredTable < ActiveRecord::Migration
  def change
  	drop_table :posts_users_hired
  	add_column :posts_users,	:status,		:string,	:default => "applied"
  	add_column :posts_users,	:user_rating,	:float,		:default => 0
  end
end
