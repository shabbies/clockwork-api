class RenamePostUsersTableToJobs < ActiveRecord::Migration
  def change
  	drop_table :posts_users
  end
end
