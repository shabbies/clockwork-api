class AddAvatarToPost < ActiveRecord::Migration
  def change
  	add_column :posts, :avatar_path, :string, :default => nil
  end
end
