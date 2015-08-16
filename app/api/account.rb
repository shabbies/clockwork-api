class Account < Grape::API
	before do
		@token = request.headers["Authentication-Token"]
    	@user = User.find_by_email_and_authentication_token(params[:email],token)
    	error!('Unauthorized - Invalid authentication token', 401) unless @user
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
		    @user.address = params[:address]
		    @user.date_of_birth = params[:date_of_birth]
		    @user.username = params[:username]
		    @user.contact_number = params[:contact_number]
		    if @user.save
		    	{ :status => 'success', :data => @user }
			else
				error!('saved failed', 422)
			end
		end

		desc "get all published jobs from user"
		params do
		    requires :email,	type: String
		end

		post :get_jobs do
		   	jobs = @user.published_jobs
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
	    	job = Post.find(params[:job_id])
	    	if job.applicants.where(:id => user.id).count == 1 || job.hired.where(:id => user.id).count == 1
	    		error!('Invalid application, you have already applied', 422)
	    	end

	    	@user.applied_jobs << job
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
	    	job = Post.find(params[:job_id])
	    	@user.applied_jobs.delete(job)
	    	job.status = "listed" unless job.applicants.count != 0

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
	    	applicant = User.find(params[:applicant_id])
	    	job = Post.find(params[:job_id])
	    	error!("Invalid job applicant", 400) unless job.applicants.where(:id => applicant.id).count != 0
	    	
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
	    	jobs = @user.applied_jobs
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
	    		if job.status == "applied" && job.hired.where(:id => @user.id).count != 0
	    			job_hash[:status] = "accepted"
	    		else
	    			job_hash[:status] = "pending"
	    		end
	    		job_array << job_hash
	    	end
		    job_array.to_json
		end
	end
end