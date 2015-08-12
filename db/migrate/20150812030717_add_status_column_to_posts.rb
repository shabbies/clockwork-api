class AddStatusColumnToPosts < ActiveRecord::Migration
  def self.up
  	add_column 	:posts, 	:status, 	:string, 	:default => "listed"
  end

  def self.down
  	remove_column 	:users, 	:status
  end
end
