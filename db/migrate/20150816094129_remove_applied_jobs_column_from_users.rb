class RemoveAppliedJobsColumnFromUsers < ActiveRecord::Migration
  def change
  	remove_column :users, :applied_jobs
  end
end
