class Account < Grape::API
	before do
		token = request.headers["Authentication-Token"]
    	@user = User.find_by_email_and_authentication_token(params[:email],token)
    	error!('Unauthorised - Invalid authentication token', 401) unless @user
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
			if params[:date_of_birth]
				date_of_birth = Date.parse(params[:date_of_birth])
				error!("Bad Request - You should be at least 15 years old", 400) if date_of_birth > Date.today - (15 * 365)
			end

		    @user.address = params[:address]
		    @user.date_of_birth = date_of_birth
		    @user.username = params[:username]
		    @user.contact_number = params[:contact_number]
		    if @user.save
		    	status 200
		    	@user.to_json
			else
				error!("Save has failed, please inform the administrator", 500)
			end
		end

		desc "get all published jobs from user"
		params do
		    requires :email,	type: String
		end

		post :get_jobs do
			error!("Bad Request - Only employers are allowed to view their published jobs", 400) unless @user.account_type == "employer"

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
	    		job_hash[:applicant_count] = Matching.where(:post_id => job.id).count
	    		job_array << job_hash
	    	end

	    	status 200
		    job_array.to_json
		end

		desc "apply for job"
		params do
		    requires :email,	type: String
		    requires :post_id,	type: Integer
		end

		post :apply do
	    	post = Post.where(:id => params[:post_id]).first
	    	matching = Matching.where(:post_id => post, :applicant_id => @user.id).first

	    	error!("Bad Request - Post not found", 400) unless post
	    	error!("Bad Request - User has already applied", 403) if matching
	    	error!("Bad Request - Only job seekers are allowed to apply for a job", 400) if @user.account_type == "employer"

	    	post.applicants << @user
	    	post.status = "applied"
	    	post.save

	    	status 200
	    	post.to_json
		end

		desc "withdraw job application"
		params do
		    requires :email,	type: String
		    requires :post_id,	type: Integer
		end

		post :withdraw do
	    	post = Post.where(:id => params[:post_id]).first
	    	account_type = @user.account_type

			error!("Bad Request - Only job seekers are allowed to withdraw from a job", 400) if account_type == "employer"
	    	error!("Bad Request - Post cannot be found.", 400) unless post

	    	matching = Matching.where(:applicant_id => @user.id, :post_id => post.id).first

	    	error!("Bad Request - You can only withdraw a pending application", 400) unless matching.status == "pending" 

	    	matching.destroy!

	    	if Matching.where(:post_id => post.id).count == 0
	    		post.status = "listed"
	    		post.save
	    	end

	    	status 200
	    	@user.jobs.to_json
		end

		desc "hire applicant"
		params do
			requires :email,		type: String
			requires :applicant_id,	type: Integer
			requires :post_id,		type: Integer
		end

		post :hire do
	    	matching = Matching.where(:applicant_id => params[:applicant_id], :post_id => params[:post_id]).first
	    	
	    	error!("Bad Request - Invalid job applicant / post", 400) unless matching
	    	error!("Bad Request - You have already hired this person", 403) unless matching.status == "pending"
	    	
	    	matching.status = "hired"
	    	matching.save

	    	status 200
	    	matching.to_json
		end

		desc "get all applied jobs from user"
		params do
		    requires :email,	type: String
		end

		post :get_applied_jobs do
			error!("Bad Request - Only job seekers are allowed to view their applications", 400) if account_type == "employer"

	    	matchings = Matching.where(:applicant_id => @user.id)
	    	job_array = Array.new
	    	matchings.each do |matching|
	    		job = Post.find(matching.post_id)
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
	    		job_hash[:status] = matching.status
	    		job_array << job_hash
	    	end

	    	status 200
		    job_array.to_json
		end
	end
end