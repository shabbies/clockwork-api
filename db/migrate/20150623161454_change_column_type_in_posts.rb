class ChangeColumnTypeInPosts < ActiveRecord::Migration
  def self.up
    change_column :posts, :posting_date, :string
    change_column :posts, :job_date, :string
  end
 
  def self.down
    change_column :posts, :posting_date, 'date USING CAST(posting_date AS date)'
    change_column :posts, :job_date, 'date USING CAST(job_date AS date)'
  end
end
