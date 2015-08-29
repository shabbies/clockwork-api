class UpdatePostsForExpiry < ActiveRecord::Migration
  def change
  	change_column 	:posts, :salary, 		:float
  	add_column		:posts, :duration, 		:integer
  	add_column		:posts,	:start_time,	:string
  end
end
