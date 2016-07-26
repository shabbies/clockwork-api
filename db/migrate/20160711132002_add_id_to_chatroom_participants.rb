class AddIdToChatroomParticipants < ActiveRecord::Migration
  def change
  	add_column :chatroom_participants, :id, :primary_key
  end
end
