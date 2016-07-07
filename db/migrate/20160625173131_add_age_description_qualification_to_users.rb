class AddAgeDescriptionQualificationToUsers < ActiveRecord::Migration
  def self.up
  	add_column 	:users,	:description, 	:text, 		:default => nil
  	add_column	:users,	:nric,					:string, 	:default => nil
  	add_column	:users,	:qualification,	:string,	:default => nil
  end

  def self.down
  	remove_column	:users,	:description
  	remove_column	:users,	:nric
  	remove_column	:users,	:qualification
  end
end
