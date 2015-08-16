class CreateMatchings < ActiveRecord::Migration
  def change
    create_table :matchings do |t|
    	t.belongs_to 	:applicant, :class_name => "User"
    	t.belongs_to 	:post
    	t.string 		:status, :default => "applied"
    	t.float			:user_rating
      	t.timestamps 	null: false
    end
  end
end
