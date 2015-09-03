class AddUserRatingsToUsers < ActiveRecord::Migration
  def change
  	add_column :users, :good_rating, 	:integer, :default => 0
  	add_column :users, :neutral_rating, :integer, :default => 0
  	add_column :users, :bad_rating, 	:integer, :default => 0
  end
end
