class CreateChatroomParticipants < ActiveRecord::Migration
  def change
    create_table :chatroom_participants, id: false do |t|
    	t.integer :chatroom_id, 		null: false
    	t.integer :user_id, 				null: false	

      t.timestamps null: false
    end
  end
end
