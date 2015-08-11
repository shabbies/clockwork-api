class AddUsersToPost < ActiveRecord::Migration
  def change
    add_column :posts, :owner_id, :integer, index: true
    add_foreign_key :posts, :users, column: :owner_id
  end
end
