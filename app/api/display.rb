class Display < Grape::API
	resource :posts do	
		# GET: /api/v1/posts/all.json
		desc "List all Posts"
		params do
			optional :user_id,	type: Integer
		end
	    get :all, :http_codes => [200, "Get successful"]  do
	    	user = User.where(:id => params[:user_id]).first
	      	posts = (user) ? Post.near(user.address, 99999999999).where.not(:status => ["expired", "completed", "reviewing"]).all : Post.where.not(:status => ["expired", "completed"]).all
	      	if posts.count == 0
	      		posts = Post.where.not(:status => ["expired", "completed"]).all
	      	end
	      	return_array = Array.new
	      	posts.each do |post|
	      		expiry_date = post.expiry_date
	      		if expiry_date <= Date.today - 1
	      			matchings = Matching.where(:post_id => post.id, :status => ["hired", "completed", "reviewing"])
		  			if matchings.count != 0
		  				if matchings.where(:user_rating => nil).count != 0
		  					post.update_attributes(status: "reviewing", expiry_date: "2015-01-01")
						else
		  					post.update_attributes(status: "completed", expiry_date: "2015-01-01")
		  				end
		  			else
		  				post.update_attributes(status: "expired", expiry_date: "2015-01-01")
		  			end
	      		else
	      			return_array << post
	      		end
	      	end
	      	status 200
	      	return_array
	    end

	    desc "search API"
	    params do
			requires :query, 		type: String
		end
	    get :search, :http_codes => [200, "Get successful"] do
	      	@posts = Post.search_by_header_and_desc(params[:query]).where.not(:status => ["completed", "expired", "reviewing"]).all
	      	
	      	status 200
	      	@posts.to_json
	    end

	    # POST: /api/v1/posts/get_post
		desc "retrieve a post"
		params do
			requires :post_id, type: String
		end

		get :get_post, 
		:http_codes => [
			[400, "Bad Request - The post cannot be found"],
			[200, "Post successfully retrieved"]
		] do
			post = Post.where(:id => params[:post_id]).first
			error!("Bad Request - The post cannot be found", 400) unless post

		   	status 200
		   	post.to_json
		end
	end

##########################################################################################################################
	resource :users do
		params do
			requires :id, 		type: String, desc: "User ID"
		end

	    get :get_calendar_formatted_dates, :http_codes => [200, "Get successful"] do
	    	user = User.where(:id => params[:id]).first
	    	job_array = Array.new

	    	if user
		    	matchings = Matching.where(:applicant_id => user.id).where.not(:status => "completed").all

		    	matchings.each do |match|
		    		job = Post.find(match.post_id)
		    		start_date = job.job_date
		    		end_date = (job.end_date + 1)

	    			job_hash = Hash.new
		    		job_hash[:title] = job.header
		    		job_hash[:job_date] = start_date.to_s
		    		job_hash[:end_date] = end_date.to_s
		    		if match.status == "hired"
		    			job_hash[:color] = "#028482"
		    		else
		    			job_hash[:color] = "#FF6600"
		    		end
		    		job_array << job_hash
		    	end
		    end
	    	job_array.to_json
		end
	end
end