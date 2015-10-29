class AddUniqueToContactNumberOfUsers < ActiveRecord::Migration
  def change
  	add_index :users, :contact_number, :unique => true
  end
end
