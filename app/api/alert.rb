class Alert < Grape::API
	before do
		token = request.headers["Authentication-Token"]
    	@user = User.find_by_email_and_authentication_token(params[:email],token)
    	error!('Unauthorised - Invalid authentication token', 401) unless @user
	end

	resource :notifications do	
		
		desc "Register / authorise device for notifications"
		params do
			requires :device_id, 		type: String
			requires :email,			type: String
			requires :device_type,		type: String,	desc: "Device type: ios / android"
		end
	    post :register, :http_codes => [
	    	[200, "Authorise successful"],
	    	[401, "Unauthorised - Invalid authentication token"],
	    	[400, "Invalid device type - should be iOS or android"]
	    ] do
	      	
	    	device_type = params[:device_type].downcase
	    	error!("Invalid device type - should be iOS or android", 400) unless device_type == "ios" || device_type == "android"
	      	
	      	existing_device = Device.where(device_id: params[:device_id], owner_id: @user.id).first
	      	unless existing_device
	      		Device.create!({
				    device_id: params[:device_id],
				    owner_id: @user.id,
				    device_type: device_type
			    })
	      	end
	      	status 200
	    end

	    desc "Unsubscribe device for notifications"
		params do
			requires :device_id, 		type: String
			requires :email,			type: String
			requires :device_type,		type: String
		end
	    post :unsub, :http_codes => [
	    	[200, "Unauthorise successful"],
	    	[401, "Unauthorised - Invalid authentication token"],
	    	[400, "Device not found"]
	    ] do
	    	device = Device.where(device_id: params[:device_id], owner_id: @user.id, device_type: params[:device_type]).first
	      	
	      	error!("Device not found", 400) unless device
	      	device.status = "unsubscribed"
	      	device.save!

	      	status 200
	    end

	    desc "Update device id"
		params do
			requires :device_id, 		type: String
			requires :new_device_id,	type: String
			requires :email,			type: String
			requires :device_type,		type: String
		end
	    post :unsub, :http_codes => [
	    	[200, "Update successful"],
	    	[401, "Unauthorised - Invalid authentication token"],
	    	[400, "Device not found"]
	    ] do
	    	device = Device.where(device_id: params[:device_id], owner_id: @user.id, device_type: params[:device_type]).first
	      	
	      	error!("Device not found", 400) unless device

	      	device.device_id = params[:new_device_id]
	      	device.status = "subscribed"
	      	device.save!
	      	
	      	status 200
	    end

	    desc "Re-subscribe device for notifications"
		params do
			requires :device_id, 		type: String
			requires :email,			type: String
			requires :device_type,		type: String
		end
	    post :resub, :http_codes => [
	    	[200, "Resubscribe successful"],
	    	[401, "Unauthorised - Invalid authentication token"],
	    	[400, "Device not found"]
	    ] do
	    	device = Device.where(device_id: params[:device_id], owner_id: @user.id, device_type: params[:device_type]).first
	      	
	      	error!("Device not found", 400) unless device
	      	device.status = "subscribed"
	      	device.save!
	      	
	      	status 200
	    end
	end
end