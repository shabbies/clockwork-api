class Notification < ActiveRecord::Base
	before_save :send_mobile_notification
	belongs_to 	:sender, 		:class_name => "User", 	:foreign_key => "sender_id"
	belongs_to 	:receiver, 		:class_name => "User", 	:foreign_key => "receiver_id"

	def self.send_notification(type, sender, recipient, post)
		message = ""
		case type
		when "job_invitation"
			message = "You have been invited to apply for the #{post.header} job!"
		end
		Notification.create!(:sender_id => sender.id, :receiver_id => recipient.id, :content => message, :avatar_path => sender.avatar_path, :post_id => post.id)
	end

	private
	def send_mobile_notification
		devices = Device.where(owner_id: receiver_id, status: "subscribed").all
		devices.each do |device|
			if device.device_type == "ios"
				n = Rpush::Apns::Notification.new
				n.app = Rpush::Apns::App.find_by_name("ios_app")
				n.device_token = "#{device.device_id}"
				n.alert = content
				n.save!
			else
				n = Rpush::Gcm::Notification.new
				n.app = Rpush::Gcm::App.find_by_name("android_app")
				n.registration_ids = "#{device.device_id}"
				type = "post"
				if content.include?("rated")
					type = "rate"
				end
				n.data = { message: content, type: type }
				n.save!
			end
		end
	end
end
