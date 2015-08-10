class ChangeContactNumberColumnTypeToInt < ActiveRecord::Migration
  def self.up
  	change_column 	:users, :date_of_birth, 	:string
  	change_column	:users,	:contact_number,	'integer USING CAST(contact_number AS integer)'
  end

  def self.down
    change_column :users, :date_of_birth, 	'date USING CAST(date_of_birth AS date)'
    change_column :users, :contact_number, 	:string
  end
end
