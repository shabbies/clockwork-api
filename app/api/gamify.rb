class Gamify < Grape::API
	before do
		token = request.headers["Authentication-Token"]
    	@user = User.find_by_email_and_authentication_token(params[:email],token)
    	error!('Unauthorised - Invalid authentication token', 401) unless @user
	end

	resource :gamify do	
		desc "Get Score"
		params do
			requires :email,			type: String
		end
	    post :get_score, :http_codes => [
	    	[200, "Get score successful"],
	    	[401, "Unauthorised - Invalid authentication token"]
	    ] do
	    	return_hash = Hash.new
	      	inner_hash = Hash.new
	      	score = Score.where(owner_id: @user.id).first
	      	score.attributes.each_pair do |name, value|
	      		next if name == "id" || name == "created_at" || name == "updated_at" || name =="owner_id"
	      		name = name.gsub("_", " ")
	      		processed_name = name.split.map(&:capitalize).join(' ')
	      		inner_hash[processed_name] = value
	      	end
	      	return_hash["scores"] = inner_hash

	      	status 200
	      	return_hash.to_json
	    end
	end
end