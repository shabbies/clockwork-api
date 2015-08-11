class AddUsersToPosts < ActiveRecord::Migration
  def change
  	add_column :users, :applied_jobs, :integer, index: true
    add_foreign_key :users, :posts, column: :applied_jobs
  end
end
