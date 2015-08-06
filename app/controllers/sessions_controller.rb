class SessionsController < Devise::SessionsController 
	skip_before_action :verify_authenticity_token
	clear_respond_to
    respond_to :json

    def create
    	self.resource = warden.authenticate!(auth_options)
	    sign_in(resource_name, resource)
	    yield resource if block_given?
	    respond_with resource, :location => after_sign_in_path_for(resource) do |format|
	    	resource.save
	      	format.json {render :json => resource } # this code will get executed for json request
	    end
    end

 	def destroy
	    signed_out = (Devise.sign_out_all_scopes ? sign_out : sign_out(resource_name))
	    respond_to do |format|
	        format.json { render :json => { 
	        	:success => true,
	        	:message => "user has been successfully signed out"
        	}}
	    end
  	end
end  