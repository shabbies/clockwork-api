class AddAvatarToUsers < ActiveRecord::Migration
  def self.up
  	add_column 		:users,	:avatar_path, 	:string, 		:default => nil
  	add_attachment	:users,	:avatar,		:default => nil	
  end

  def self.down
  	remove_attachment 	:users, 	:avatar
  	remove_column		:users,		:avatar_path
  end
end
