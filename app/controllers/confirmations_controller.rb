class ConfirmationsController < Devise::ConfirmationsController
	def show
	    self.resource = resource_class.confirm_by_token(params[:confirmation_token])
	    yield resource if block_given?

	    if resource.errors.empty?
			set_flash_message(:notice, :confirmed) if is_flashing_format?
			respond_with_navigational(resource){ redirect_to after_confirmation_path_for(resource_name, resource) }
	    else
			request_url = request.original_url
			if request_url.include? "localhost"
				redirect_to "http://localhost:8080/registration_failure.jsp"
			elsif request_url.include? "staging"
				redirect_to "http://www.staging-clockworksmu.herokuapp.com/registration_failure.jsp"
			else
				redirect_to "http://www.clockworksmu.herokuapp.com/registration_failure.jsp"
			end
	    end
  	end

	private

	def after_confirmation_path_for(resource_name, resource)
		request_url = request.original_url
		if request_url.include? "localhost"
			"http://localhost:8080/registration_success.jsp?t=#{resource.confirmation_token}"
		elsif request_url.include? "staging"
			"http://www.staging-clockworksmu.herokuapp.com/registration_success.jsp?t=#{resource.confirmation_token}"
		else
			"http://www.clockworksmu.herokuapp.com/registration_success.jsp?t=#{resource.confirmation_token}"
		end
	end
end