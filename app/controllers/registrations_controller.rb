class RegistrationsController < Devise::RegistrationsController  
    skip_before_action :verify_authenticity_token
    clear_respond_to  
    respond_to :json

    def sign_up_params
    	params.require(:user).permit(:email, :password, :password_confirmation, :username, :company_name, :account_type, :facebook_id)
  	end

  	def create
  		build_resource(sign_up_params)
  		if sign_up_params[:facebook_id]
  			existing_user = User.find_by("email" => sign_up_params[:email])
  			if existing_user
  				existing_user.facebook_id = sign_up_params[:facebook_id]
  				existing_user.save
  				respond_with existing_user, location: after_sign_up_path_for(existing_user)
  				return
  			else
	  			password = Devise.friendly_token.first(8)
	  			resource.password = password
	  			resource.password_confirmation = password
	  		end
  		end

	    if resource.save
	      yield resource if block_given?
	      if resource.active_for_authentication?
	        set_flash_message :notice, :signed_up if is_flashing_format?
	        sign_up(resource_name, resource)
	        respond_with resource, location: after_sign_up_path_for(resource)
	      else
	        set_flash_message :notice, :"signed_up_but_#{resource.inactive_message}" if is_flashing_format?
	        expire_data_after_sign_in!
	        respond_with resource, location: after_inactive_sign_up_path_for(resource)
	      end
	    else
	      clean_up_passwords resource
	      respond_with resource
	    end
	end
end  