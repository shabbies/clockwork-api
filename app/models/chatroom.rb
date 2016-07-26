class Chatroom < ActiveRecord::Base
	has_many :messages,			:class_name => "ChatMessage"
	has_many :chatroom_participants
  has_many :users, through: :chatroom_participants
end
