class Competition < Grape::API
	resource :competition do
		params do
			requires :email, 	type: String, desc: "User Email"
			requires :name,		type: String, desc: "User Full Name"
		end

	    post :competition_register, 
	    :http_codes => [
	    	[200, "Register successful"],
	    	[400, "Invalid email"]
    	] do
	    	contest = Contest.new(email: params[:email], name: params[:name])
	    	if contest.save
	    		status 200
	    	else
	    		error!("Invalid email", 400)
	    	end
		end
	end
end