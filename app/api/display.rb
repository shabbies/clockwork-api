class Display < Grape::API
	resource :posts do	
		# GET: /api/v1/posts/all.json
		desc "List all Posts"
	    get :all, :http_codes => [200, "Get successful"]  do
	      	posts = Post.where.not(:status => ["expired", "completed"]).all
	      	return_array = Array.new
	      	posts.each do |post|
	      		expiry_date = Date.strptime(post.expiry_date, '%Y-%m-%d')
	      		if expiry_date <= Date.today - 1
	      			matchings = Matching.where(:post_id => post.id, :status => ["hired", "completed", "reviewing"])
	      			if matchings.count != 0
	      				if matchings.where(:user_rating => nil).count != 0
	      					post.status = "reviewing"
	      				else
	      					post.status = "completed"
	      				end
	      			else
	      				post.status = "expired"
	      			end
	      			post.save
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
	      	@posts = Post.search_by_header_and_desc(params[:query]).where.not(:status => ["completed", "expired"]).all
	      	
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
		   	post
		end

	    desc "expire post - for dev only"
	    params do
			requires :id, 		type: String
		end
	    get :dev_expire_post, :http_codes => [200, "Get successful"] do
	      	post = Post.find(params[:id])
	      	post.expiry_date = "2015-01-01"
	      	matchings = Matching.where(:post_id => post.id, :status => ["hired", "completed", "reviewing"])
  			if matchings.count != 0
  				if matchings.where(:user_rating => nil).count != 0
  					post.status = "reviewing"
  				else
  					post.status = "completed"
  				end
  			else
  				post.status = "expired"
  			end
  			post.save

  			status 200
	    end  
	end

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
		    		start_date = Date.parse(job.job_date)
		    		end_date = Date.parse(job.end_date)

		    		while start_date <= end_date
		    			job_hash = Hash.new
			    		job_hash[:title] = job.header
			    		job_hash[:job_date] = start_date.to_s
			    		if match.status == "hired"
			    			job_hash[:color] = "#028482"
			    		else
			    			job_hash[:color] = "#FF6600"
			    		end
			    		job_array << job_hash
			    		start_date += 1
		    		end
		    	end
		    end
	    	job_array.to_json
		end
	end
end