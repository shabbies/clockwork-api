class DropNricFromUsers < ActiveRecord::Migration
  def change
  	remove_column :users, :nric
  end
end
