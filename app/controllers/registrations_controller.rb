class RegistrationsController < Devise::RegistrationsController  
    skip_before_action :verify_authenticity_token
    clear_respond_to  
    respond_to :json

    def sign_up_params
    	params.require(:user).permit(:email, :password, :password_confirmation, :username, :company_name, :account_type)
  	end
end  