class CreatePosts < ActiveRecord::Migration
  def change
    create_table :posts do |t|
      t.string :header
      t.string :company
      t.integer :salary
      t.text :description
      t.string :location
      t.date :posting_date
      t.date :job_date

      t.timestamps null: false
    end
  end
end
