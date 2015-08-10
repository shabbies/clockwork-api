class AddAddressContactNumberAndDateOfBirthToUsers < ActiveRecord::Migration
  def self.up
  	add_column 	:users, :address, 			:string, 	:default => nil
  	add_column	:users, :contact_number,	:string, 	:default => nil
  	add_column	:users,	:date_of_birth,		:date, 		:default => nil	
  end

  def self.down
  	remove_column 	:users, :address
  	remove_column	:users,	:contact_number
  	remove_column	:users,	:date_of_birth
  end
end
