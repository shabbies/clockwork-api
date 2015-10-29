class AddLatitudeAndLongitudeToPost < ActiveRecord::Migration
  def change
    add_column :posts, :latitude, :float
    add_column :posts, :longitude, :float

    add_column :users, :latitude, :float
    add_column :users, :longitude, :float
  end
end
