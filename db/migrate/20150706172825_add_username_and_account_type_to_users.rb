class AddUsernameAndAccountTypeToUsers < ActiveRecord::Migration
  def self.up
  	add_column :users, :account_type, :string
  	add_column :users, :username, :string
  end

  def self.down
  end
end
