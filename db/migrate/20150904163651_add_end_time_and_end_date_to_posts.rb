class AddEndTimeAndEndDateToPosts < ActiveRecord::Migration
  def change
  	add_column :posts, :end_date, :string
  	add_column :posts, :end_time, :string
  end
end
