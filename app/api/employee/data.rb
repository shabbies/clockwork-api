module Employee
  	class Data < Grape::API 

	    resource :posts do	
	    	# GET: /api/v1/posts/all.json
	    	desc "List all Posts"
		    get :all do
		      	Post.all
		    end

		    # POST: /api/v1/posts/new
		    desc "create a new post"
			## This takes care of parameter validation
			params do
				requires :email, 		type: String
			    requires :header, 		type: String
			    requires :company, 		type: String
			    requires :salary, 		type: Integer
			    requires :description, 	type: String
			    requires :location,	 	type: String
			    requires :job_date,		type: String
			end

			## This takes care of creating post
			post :new do
				token = request.headers["Authentication-Token"]
		    	user = User.find_by_email_and_authentication_token(params[:email],token)
		    	error!('Unauthorized - Invalid authentication token', 401) unless user

			    post = Post.create!({
				    header: params[:header],
				    company: params[:company],
				    salary: params[:salary],
				    description: params[:description],
				    location: params[:location],
				    posting_date: Date.today,
				    job_date: Date.parse(params[:job_date]),
				    status: "listed"
			    })
			    user.published_jobs << post
			    user.save

			    { 
			    	message: "post is successfully created",
			    	status: 201,
			    	post_id: post.id
			    }
			end

			# POST: /api/v1/posts/delete
			desc "deletes a post"
			params do
				requires :id, type: String
			end
			post :delete do
			    Post.find(params[:id]).destroy!
			    { 
			    	message: "post is successfully deleted",
			    	status: 200
			    }
			end

			desc "updates a post"
			params do
				requires :email,		type: String
				requires :header, 		type: String
			    requires :salary, 		type: Integer
			    requires :description, 	type: String
			    requires :location,	 	type: String
			    requires :id,			type: String
			    requires :job_date,		type: String
			end
			post :update do
				token = request.headers["Authentication-Token"]
		    	user = User.find_by_email_and_authentication_token(params[:email],token)
		    	error!('Unauthorized - Invalid authentication token', 401) unless user

		    	post = Post.find(params[:id])
		    	error!('Unauthorized - Only owner allowed to edit post', 401) unless post.owner == user

			    post.update({
			    	header: params[:header],
				    salary: params[:salary],
				    description: params[:description],
				    location: params[:location],
				    job_date: Date.parse(params[:job_date])
			    })
			    post.to_json
			end

			desc "get applicants"
			params do
				requires :email,		type: String
				requires :job_id,		type: Integer
			end

			post :get_applicants do
				token = request.headers["Authentication-Token"]
		    	user = User.find_by_email_and_authentication_token(params[:email],token)
		    	error!('Unauthorized - Invalid authentication token', 401) unless user

		    	job = Post.find(params[:job_id])
		    	error!("Post not found", 422) unless job
		    	error!("Unauthorized - Only owner can view applicants", 400) unless job.owner == user
		    	
		    	job.applicants.to_json
			end

			desc "get hired list"
			params do
				requires :email,		type: String
				requires :job_id,		type: Integer
			end

			post :get_hired do
				token = request.headers["Authentication-Token"]
		    	user = User.find_by_email_and_authentication_token(params[:email],token)
		    	error!('Unauthorized - Invalid authentication token', 401) unless user

		    	job = Post.find(params[:job_id])
		    	error!("Post not found", 422) unless job
		    	error!("Unauthorized - Only owner can view applicants", 400) unless job.owner == user
		    	
		    	job.hired.to_json
			end
	    end 

	    resource :users do
	    	desc "updates a user"
			params do
				requires :email, 			type: String
			    requires :address, 			type: String
			    requires :date_of_birth, 	type: String
			    requires :username, 		type: String
			    requires :contact_number,	type: Integer
			end

			post :update do
				token = request.headers["Authentication-Token"]
		    	user = User.find_by_email_and_authentication_token(params[:email],token)
		    	error!('Unauthorized - Invalid authentication token', 401) unless user

			    user = User.find_by_email(params[:email])
			    user.address = params[:address]
			    user.date_of_birth = params[:date_of_birth]
			    user.username = params[:username]
			    user.contact_number = params[:contact_number]
			    if user.save
			    	{ :status => 'success', :data => user }
				else
					error!('saved failed', 422)
				end
			end

			desc "get all published jobs from user"
			params do
			    requires :email,	type: String
			end

			post :get_jobs do
				token = request.headers["Authentication-Token"]
		    	user = User.find_by_email_and_authentication_token(params[:email],token)
		    	error!('Unauthorized - Invalid authentication token', 401) unless user

		    	jobs = user.published_jobs
		    	job_array = Array.new
		    	jobs.each do |job|
		    		job_hash = Hash.new
		    		job_hash[:owner_id] = job.owner_id
		    		job_hash[:id] = job.id
		    		job_hash[:header] = job.header
		    		job_hash[:company] = job.company
		    		job_hash[:salary] = job.salary
		    		job_hash[:description] = job.description
		    		job_hash[:location] = job.location
		    		job_hash[:posting_date] = job.posting_date
		    		job_hash[:job_date] = job.job_date
		    		job_hash[:status] = job.status
		    		job_hash[:applicant_count] = job.applicants.count
		    		job_array << job_hash
		    	end
			    job_array.to_json
			end

			desc "apply for job"
			params do
			    requires :email,	type: String
			    requires :job_id,	type: Integer
			end

			post :apply do
				token = request.headers["Authentication-Token"]
		    	user = User.find_by_email_and_authentication_token(params[:email],token)
		    	error!('Unauthorized - Invalid authentication token', 401) unless user

		    	job = Post.find(params[:job_id])
		    	if job.applicants.where(:id => user.id).count == 1 || job.hired.where(:id => user.id).count == 1
		    		error!('Invalid application, you have already applied', 422)
		    	end

		    	user.applied_jobs << job
		    	job.status = "applied"
		    	job.save

		    	job.to_json
			end

			desc "withdraw job application"
			params do
			    requires :email,	type: String
			    requires :job_id,	type: Integer
			end

			post :withdraw do
				token = request.headers["Authentication-Token"]
		    	user = User.find_by_email_and_authentication_token(params[:email],token)
		    	error!('Unauthorized - Invalid authentication token', 401) unless user

		    	job = Post.find(params[:job_id])
		    	user.applied_jobs.delete(job)
		    	job.status = "listed" unless job.applicants

		    	job.save
		    	job.to_json
			end

			desc "hire applicant"
			params do
				requires :email,		type: String
				requires :applicant_id,	type: Integer
				requires :job_id,		type: Integer
			end

			post :hire do
				token = request.headers["Authentication-Token"]
		    	user = User.find_by_email_and_authentication_token(params[:email],token)
		    	error!('Unauthorized - Invalid authentication token', 401) unless user

		    	applicant = User.find(params[:applicant_id])
		    	job = Post.find(params[:job_id])
		    	error!("Invalid job applicant", 400) unless job.applicants.find(applicant)
		    	
		    	applicant = job.applicants.find(params[:applicant_id])
		    	job.applicants.delete(applicant)
		    	job.hired << applicant
		    	job.hired.to_json
			end

			desc "get all applied jobs from user"
			params do
			    requires :email,	type: String
			end

			post :get_applied_jobs do
				token = request.headers["Authentication-Token"]
		    	user = User.find_by_email_and_authentication_token(params[:email],token)
		    	error!('Unauthorized - Invalid authentication token', 401) unless user

		    	jobs = user.applied_jobs
		    	job_array = Array.new
		    	jobs.each do |job|
		    		job_hash = Hash.new
		    		job_hash[:owner_id] = job.owner_id
		    		job_hash[:id] = job.id
		    		job_hash[:header] = job.header
		    		job_hash[:company] = job.company
		    		job_hash[:salary] = job.salary
		    		job_hash[:description] = job.description
		    		job_hash[:location] = job.location
		    		job_hash[:posting_date] = job.posting_date
		    		job_hash[:job_date] = job.job_date
		    		if job.status == "applied" && job.hired.where(:id => user.id).count != 0
		    			job_hash[:status] = "accepted"
		    		else
		    			job_hash[:status] = "pending"
		    		end
		    		job_array << job_hash
		    	end
			    job_array.to_json
			end


			desc "get jobs for calendar"
			params do
				requires :id,		type: Integer
			end

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
end