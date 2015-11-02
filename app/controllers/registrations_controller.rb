class RegistrationsController < Devise::RegistrationsController  
	#before_filter :configure_permitted_parameters, :only => :update
    skip_before_action :verify_authenticity_token
    clear_respond_to  
    respond_to :json

  	def create
  		build_resource(sign_up_params)

  		if sign_up_params[:facebook_id]
  			existing_user = User.find_by("email" => sign_up_params[:email])
  			if existing_user
  				existing_user.facebook_id = sign_up_params[:facebook_id]
  				existing_user.avatar_path = sign_up_params[:avatar_path] unless existing_user.avatar
  				existing_user.save
  				session[:user_id] = existing_user.id
  				respond_with existing_user, location: after_sign_up_path_for(existing_user)
  				return
  			else
	  			password = Devise.friendly_token.first(8)
	  			resource.password = password
	  			resource.password_confirmation = password
	  			resource.avatar_path = sign_up_params[:avatar_path]
	  		end
  		end

      if sign_up_params[:referred_by]
        referrer = User.where(referral_id: sign_up_params[:referred_by]).first
        if referrer
          referrer.referred_users += 1
          referrer.save!
        else 
          resource.referred_by = nil
        end
      end

	    if resource.save
        Score.create!(owner_id: resource.id) if resource.account_type == "job_seeker"
        QuestionHistory.create!(owner_id: resource.id) if resource.account_type == "job_seeker"
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

	private
    def sign_up_params
    	params.require(:user).permit(:id, :email, :password, :password_confirmation, :username, :company_name, :account_type, :facebook_id, :address, :contact_number, :date_of_birth, :avatar_path, :referred_by)
  	end

end  