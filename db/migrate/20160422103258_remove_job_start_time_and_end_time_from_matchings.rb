class RemoveJobStartTimeAndEndTimeFromMatchings < ActiveRecord::Migration
  def change
  	remove_column :matchings, :job_start_time
  	remove_column :matchings, :job_end_time
  end
end
