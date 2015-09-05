class Display < Grape::API
	resource :posts do	
		# GET: /api/v1/posts/all.json
		desc "List all Posts"
	    get :all, :http_codes => [200, "Get successful"]  do
	      	all_post = Post.where.not(:status => "expired").all
	      	return_array = Array.new
	      	all_post.each do |post|
	      		expiry_date = Date.strptime(post.expiry_date, '%Y-%m-%d')
	      		if expiry_date <= Date.today - 1
	      			if Matching.where(:post_id => post.id, :status => ["hired", "completed"]).count != 0
	      				post.status = "completed"
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

	    desc "List all Posts sorted by salary"
	    get :all_salary, :http_codes => [200, "Get successful"] do
	      	Post.where.not(:status => ["expired", "completed"]).order(:salary).reverse_order
	    end

	    desc "List all Posts sorted by latest first"
	    get :all_latest, :http_codes => [200, "Get successful"] do
	      	Post.where.not(:status => ["expired", "completed"]).order(:created_at).reverse_order
	    end

	    desc "List all Posts sorted by oldest first"
	    get :all_oldest, :http_codes => [200, "Get successful"] do
	      	Post.where.not(:status => ["expired", "completed"]).order(:created_at)
	    end

	    desc "search API"
	    params do
			requires :query, 		type: String
		end
	    get :search, :http_codes => [200, "Get successful"] do
	      	Post.where.not(:status => ["expired", "completed"]).order(:created_at)
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
		    	matchings = Matching.where(:applicant_id).where.not(:status => "completed").all

		    	matchings.each do |match|
		    		job = Post.find(match.post_id)
		    		job_hash = Hash.new
		    		job_hash[:title] = job.header
		    		job_hash[:start_date] = job.job_date
		    		if matching.status == "hired"
		    			job_hash[:color] = "#777777"
		    		else
		    			job_hash[:color] = "#4c4c4c"
		    		end
		    		job_array << job_hash
		    	end
		    end
	    	job_array.to_json
		end
	end
end