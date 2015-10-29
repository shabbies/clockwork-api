class AddDefaultLocationToUsers < ActiveRecord::Migration
  def change
  	change_column :users, :address, :string, :default => "Singapore"
  end
end
