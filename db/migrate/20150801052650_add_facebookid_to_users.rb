class AddFacebookidToUsers < ActiveRecord::Migration
  def self.up
  	add_column 	:users, 	:facebook_id, 	:string, 	:default => nil
  end

  def self.down
  	remove_column 	:users, 	:facebook_id
  end
end
