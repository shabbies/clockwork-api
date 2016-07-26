class AddPostIdToChatroomParticipants < ActiveRecord::Migration
  def change
  	add_column :chatroom_participants, :post_id, :integer
  end
end
