class Display < Grape::API
	resource :posts do	
		# GET: /api/v1/posts/all.json
		desc "List all Posts"
	    get :all do
	      	Post.all
	    end

	    desc "List all Posts sorted by salary"
	    get :all_salary do
	      	Post.order(:salary).reverse_order
	    end

	    desc "List all Posts sorted by latest first"
	    get :all_latest do
	      	Post.order(:created_at).reverse_order
	    end

	    desc "List all Posts sorted by oldest first"
	    get :all_oldest do
	      	Post.order(:created_at)
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