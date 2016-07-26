class ChatMessage < ActiveRecord::Base
	belongs_to 	:sender, 		:class_name => "User"
	belongs_to 	:chatroom

	def sender_name
		User.find(sender_id).username
	end

	def sender_avatar
		User.find(sender_id).avatar_path
	end

	def created_at_time
		created_at.in_time_zone
	end

	def attributes
		super.merge(sender_name: self.sender_name, sender_avatar: self.sender_avatar, created_at_time: self.created_at_time)
	end
end
