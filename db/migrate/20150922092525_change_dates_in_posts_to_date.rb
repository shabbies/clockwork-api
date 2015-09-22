class ChangeDatesInPostsToDate < ActiveRecord::Migration
  def change
  	change_column :posts, :posting_date, 'date USING CAST(posting_date AS date)'
    change_column :posts, :job_date, 'date USING CAST(job_date AS date)'
    change_column :posts, :end_date, 'date USING CAST(end_date AS date)'
    change_column :posts, :expiry_date, 'date USING CAST(expiry_date AS date)'
  end
end
