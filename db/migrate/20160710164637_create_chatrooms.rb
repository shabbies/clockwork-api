class CreateChatrooms < ActiveRecord::Migration
  def change
    create_table :chatrooms do |t|
    	t.belongs_to 	:post,	:index => true

      t.timestamps null: false
    end
  end
end
