class AddJobTimingsToMatchings < ActiveRecord::Migration
  def change
  	add_column :matchings, :job_timings, :text
  end
end
