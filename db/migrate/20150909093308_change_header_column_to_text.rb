class ChangeHeaderColumnToText < ActiveRecord::Migration
  def change
  	change_column :posts, :header, :text,		:default => nil
  	change_column :posts, :description, :text, 	:default => nil
  end
end
