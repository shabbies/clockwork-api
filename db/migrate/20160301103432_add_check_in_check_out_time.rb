class AddCheckInCheckOutTime < ActiveRecord::Migration
  def change
  	add_column :matchings, :job_start_time, :string
  	add_column :matchings, :job_end_time, :string
  end
end
