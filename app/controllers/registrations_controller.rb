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

	def update
		token = request.headers["Authentication-Token"]
    	user = User.find_by_email_and_authentication_token(account_update_params[:email],token)
    	p "BYE"
    	p token
    	p user
    	p account_update_params[:email]
    	unless user
    		p "BYE"
    	p token
    	p user
    	p account_update_params[:email]
    		render json: "Token is unauthorised", status: 401
    		return
    	end

	    self.resource = resource_class.to_adapter.get!(send(:"current_#{resource_name}").to_key)
	    prev_unconfirmed_email = resource.unconfirmed_email if resource.respond_to?(:unconfirmed_email)

	    if update_resource(resource, account_update_params)
	      	yield resource if block_given?
	      	if is_flashing_format?
	        	flash_key = update_needs_confirmation?(resource, prev_unconfirmed_email) ?
		          :update_needs_confirmation : :updated
		        set_flash_message :notice, flash_key
	      	end
	      	sign_in resource_name, resource, bypass: true
	      	render json: resource, status: 200 
	    else
      		clean_up_passwords resource
      		render json: resource.errors, status: :unprocessable_entity 
	    end
  	end

	def update_resource(resource, account_update_params)
    	resource.update_without_password(account_update_params)
  	end

  	private
    def sign_up_params
    	params.require(:user).permit(:id, :email, :password, :password_confirmation, :username, :company_name, :account_type, :facebook_id, :address, :contact_number, :date_of_birth)
  	end

  	def account_update_params
		params.require(:user).permit(:email, :username, :address, :password, :password_confirmation, :address, :contact_number, :date_of_birth)
	end

end  