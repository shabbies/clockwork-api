class CreateFavourites < ActiveRecord::Migration
  def change
    create_table :favourites do |t|
    	t.integer :owner_id,		:index => true
    	t.integer :user_id,			:index => true
      t.timestamps null: false
    end
  end
end
