class ChangeUserRatingDefault < ActiveRecord::Migration
  def change
  	change_column :matchings, :user_rating, :integer, :default => nil
  end
end
