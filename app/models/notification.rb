class Notification < ActiveRecord::Base
	before_save :send_mobile_notification
	belongs_to 	:sender, 		:class_name => "User", 	:foreign_key => "sender_id"
	belongs_to 	:receiver, 		:class_name => "User", 	:foreign_key => "receiver_id"

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
