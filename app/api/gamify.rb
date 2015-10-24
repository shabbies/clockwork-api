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
	      	inner_array = Array.new
	      	score = Score.where(owner_id: @user.id).first
	      	score.attributes.each_pair do |name, value|
	      		next if name == "id" || name == "created_at" || name == "updated_at" || name =="owner_id"
	      		inner_hash = Hash.new
	      		name = name.gsub("_", " ")
	      		processed_name = name.split.map(&:capitalize).join(' ')
	      		inner_hash["type"] = processed_name
	      		inner_hash["score"] = value
	      		inner_array << inner_hash
	      	end
	      	return_hash["scores"] = inner_array

	      	status 200
	      	return_hash.to_json
	    end

	    desc "Get All Badges"
		params do
			requires :email,			type: String
		end
	    post :get_badges, :http_codes => [
	    	[200, "Get score successful"],
	    	[401, "Unauthorised - Invalid authentication token"]
	    ] do
	    	badges = Badge.all
	    	obtained_badges = @user.obtained_badges
	    	return_array = Array.new

	    	badges.each do |badge|
    			inner_hash = Hash.new
    			inner_hash["name"] = badge.name
    			inner_hash["criteria"] = badge.criteria
    			inner_hash["badge_id"] = badge.badge_id
    			if obtained_badges.include?(badge.badge_id)
    				inner_hash["badge_image_link"] = "https://s3-ap-southeast-1.amazonaws.com/media.clockworksmu.herokuapp.com/app/public/assets/badges/#{badge.badge_id}_done.png"
    				inner_hash["status"] = "completed"
    			else
    				inner_hash["badge_image_link"] = "https://s3-ap-southeast-1.amazonaws.com/media.clockworksmu.herokuapp.com/app/public/assets/badges/#{badge.badge_id}.png"
    				inner_hash["status"] = "uncompleted"
    			end
    			return_array << inner_hash
    		end

	    	status 200
	    	return_array.to_json
	    end
	end
end