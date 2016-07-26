class AddKeysToChat < ActiveRecord::Migration
  def change
  	add_index :chatroom_participants, [:chatroom_id, :user_id], :unique => true
  end
end
