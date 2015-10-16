class Notification < ActiveRecord::Base
	belongs_to 	:sender, 		:class_name => "User", 	:foreign_key => "sender_id"
	belongs_to 	:receiver, 		:class_name => "User", 	:foreign_key => "receiver_id"

	def self.send_mobile_notification(user_id, message)
		devices = Device.where(owner_id: user_id).all
		devices.each do |device|
			if device.device_type == "ios"
				n = Rpush::Apns::Notification.new
				n.app = Rpush::Apns::App.find_by_name("ios_app")
				n.device_token = "#{device.device_id}"
				n.alert = message
				n.save!
			else
				n = Rpush::Gcm::Notification.new
				n.app = Rpush::Gcm::App.find_by_name("android_app")
				n.registration_ids = "#{device.device_id}"
				n.data = { message: message }
				n.save!
			end
		end
		Rpush.push
	end
end
