class AddCommentsToMatching < ActiveRecord::Migration
  def change
  	add_column :matchings, :comments, :string
  end
end
