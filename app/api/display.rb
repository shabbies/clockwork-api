class Display < Grape::API
	resource :posts do	
		# GET: /api/v1/posts/all.json
		desc "List all Posts"
	    get :all do
	      	all_post = Post.where.not(:status => "expired").all
	      	return_array = Array.new
	      	all_post.each do |post|
	      		expiry_date = Date.strptime(post.expiry_date, '%Y-%m-%d')
	      		if expiry_date <= Date.today - 1
	      			if Matching.where(:post_id => post.id, :status => ["hired". "completed"]).count != 0
	      				post.status = "completed"
	      			else
	      				post.status = "expired"
	      			end
	      			post.save
	      		else
	      			return_array << post
	      		end
	      	end
	      	return_array
	    end

	    desc "List all Posts sorted by salary"
	    get :all_salary do
	      	Post.where.not(:status => ["expired", "completed"]).order(:salary).reverse_order
	    end

	    desc "List all Posts sorted by latest first"
	    get :all_latest do
	      	Post.where.not(:status => ["expired", "completed"]).order(:created_at).reverse_order
	    end

	    desc "List all Posts sorted by oldest first"
	    get :all_oldest do
	      	Post.where.not(:status => ["expired", "completed"]).order(:created_at)
	    end
	end

	resource :users do
	    get :get_calendar_formatted_dates do
	    	user = User.find(params[:id])
	    	error!('Unauthorized - Invalid authentication token', 401) unless user

	    	job_array = Array.new
	    	applied_jobs = user.applied_jobs

	    	applied_jobs.each do |job|
	    		job_hash = Hash.new
	    		job_hash[:title] = job.header
	    		job_hash[:start_date] = job.job_date
	    		job_hash[:color] = "#4c4c4c"
	    		job_array << job_hash
	    	end

	    	hired_jobs = user.hired_jobs
	    	hired_jobs.each do |job|
				job_hash = Hash.new
	    		job_hash[:title] = job.header
	    		job_hash[:start_date] = job.job_date
	    		job_hash[:color] = "#777777"
	    		job_array << job_hash
	    	end

	    	job_array.to_json
		end
	end
end