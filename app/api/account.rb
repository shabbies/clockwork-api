class Account < Grape::API
	before do
		token = request.headers["Authentication-Token"]
    	@user = User.find_by_email_and_authentication_token(params[:email],token)
    	error!('Unauthorised - Invalid authentication token', 401) unless @user
	end

	resource :users do
		desc "updates a user"
		params do
			requires :email, 					type: String
			optional :date_of_birth, 			type: String
			optional :avatar, 					type: Rack::Multipart::UploadedFile, desc: "param name: avatar"
			optional :password,					type: String,	desc: "Only required when updating password"
			optional :password_confirmation, 	type: String,	desc: "Has to be the same as password"
			optional :old_password,				type: String, 	desc: "Only required when updating password"
			optional :address,					type: String
			optional :username,					type: String
			optional :contact_number,			type: String
		end

		post :update, :http_codes => [
			[401, "Unauthorised - Invalid authentication token"], 
			[400, "(1)Bad Request - You should be at least 15 years old | 
				(2)Bad Request - Passwords do not match"],
			[200, "Save successful"],
			[403, "Unauthorised - Old password is invalid"],
			[500, "Internal Server Error - save failed"]
			] do

			unless params[:date_of_birth].blank?
				date_of_birth = Date.parse(params[:date_of_birth])
				error!("Bad Request - You should be at least 15 years old", 400) if date_of_birth > Date.today - (15 * 365)
			end

			avatar = params[:avatar]
			attachment = nil
			if avatar
				attachment = {
		            :filename => avatar[:filename],
		            :type => avatar[:type],
		            :headers => avatar[:head],
		            :tempfile => avatar[:tempfile]
		        }
		    end

		    if !params[:password].blank? && !params[:password_confirmation].blank? && !params[:old_password].blank?
		    	error!("Unauthorised - Old password is invalid", 403) unless @user.valid_password?(params[:old_password])
		    	error!("Bad Request - Passwords do not match", 400) unless params[:password] == params[:password_confirmation]

		    	@user.password = params[:password]
		    end

		    @user.address = params[:address] unless params[:address].blank?
		    @user.date_of_birth = date_of_birth unless params[:date_of_birth].blank?
		    @user.username = params[:username] unless params[:username].blank?
		    @user.contact_number = params[:contact_number] unless params[:contact_number].blank?
		    if avatar
		    	@user.avatar = ActionDispatch::Http::UploadedFile.new(attachment) if avatar
		    	@user.avatar_path = @user.avatar.url
		    end
		    if @user.save
		    	status 200
		    	@user.to_json
			else
				error!("Save has failed, please inform the administrator", 500)
			end
		end

		desc "complete user profile"
		params do
			requires :email, 					type: String
			optional :date_of_birth, 			type: String
			optional :avatar, 					type: Rack::Multipart::UploadedFile, desc: "param name: avatar"
			optional :address,					type: String
			optional :username,					type: String
			optional :contact_number,			type: String
			optional :gender,					type: String
			optional :nationality,				type: String
		end

		post :complete_profile, :http_codes => [
			[401, "Unauthorised - Invalid authentication token"], 
			[400, "(1)Bad Request - You should be at least 15 years old || 
				(2)Bad Request - Invalid Gender: only M and F allowed"],
			[200, "Save successful"],
			[500, "Internal Server Error - save failed"]
			] do

			gender = params[:gender].upcase
			unless gender.blank?
				error!("Bad Request - Invalid Gender: only M and F allowed", 400) unless gender == "M" || gender == "F"
			end
			
			unless params[:date_of_birth].blank?
				date_of_birth = Date.parse(params[:date_of_birth])
				error!("Bad Request - You should be at least 15 years old", 400) if date_of_birth > Date.today - (15 * 365)
			end

			avatar = params[:avatar]
			attachment = nil
			if avatar
				attachment = {
		            :filename => avatar[:filename],
		            :type => avatar[:type],
		            :headers => avatar[:head],
		            :tempfile => avatar[:tempfile]
		        }
		    end

		    @user.address = params[:address] unless params[:address].blank?
		    @user.date_of_birth = date_of_birth unless params[:date_of_birth].blank?
		    @user.username = params[:username] unless params[:username].blank?
		    @user.contact_number = params[:contact_number] unless params[:contact_number].blank?
		    @user.gender = gender unless gender.blank?
		    @user.nationality = params[:nationality] unless params[:nationality].blank?
		    if avatar
		    	@user.avatar = ActionDispatch::Http::UploadedFile.new(attachment) if avatar
		    	@user.avatar_path = @user.avatar.url
		    end
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

		post :get_jobs, :http_codes => [
			[401, "Unauthorised - Invalid authentication token"], 
			[400, "Bad Request - Only employers are allowed to view their published jobs"],
			[200, "Returns array of published jobs"]
			] do
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
	    		job_hash[:expiry_date] = job.expiry_date
	    		job_hash[:status] = job.status
	    		job_hash[:start_time] = job.start_time
	    		job_hash[:duration] = job.duration
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

		post :apply, :http_codes => [
			[401, "Unauthorised - Invalid authentication token"], 
			[400, "(1)Bad Request - Post not found | 
				(2)Bad Request - Only job seekers are allowed to apply for a job"],
			[403, "Bad Request - User has already applied"],
			[200, "Returns post object"]
			] do
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

		post :withdraw, :http_codes => [
			[401, "Unauthorised - Invalid authentication token"], 
			[400, "(1)Bad Request - Only job seekers are allowed to withdraw from a job | 
				(2)Bad Request - Post cannot be found | 
				(3)Bad Request - You can only withdraw a pending application"],
			[200, "Returns a list of remaining user applications"]
			] do
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

		post :hire, :http_codes => [
			[401, "Unauthorised - Invalid authentication token"], 
			[400, "Bad Request - Invalid job applicant / post"],
			[200, "Returns the matching between user and job"], 
			[403, "Bad Request - You have already hired this person"] 
			] do
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

		post :get_applied_jobs, :http_codes => [
			[401, "Unauthorised - Invalid authentication token"], 
			[400, "Bad Request - Only job seekers are allowed to view their applications"],
			[200, "Returns array of applied jobs"]
			] do
			error!("Bad Request - Only job seekers are allowed to view their applications", 400) if @user.account_type == "employer"

	    	matchings = Matching.where(:applicant_id => @user.id).all
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
	    		job_hash[:expiry_date] = job.expiry_date
	    		job_hash[:start_time] = job.start_time
	    		job_hash[:duration] = job.duration
	    		job_array << job_hash
	    	end

	    	status 200
		    job_array.to_json
		end

		desc "get all applied jobs from user"
		params do
		    requires :email,	type: String
		end

		post :get_completed_jobs, :http_codes => [
			[401, "Unauthorised - Invalid authentication token"], 
			[400, "Bad Request - Only job seekers are allowed to view their applications"],
			[200, "Returns array of completed jobs"] 
			] do
			error!("Bad Request - Only job seekers are allowed to view their applications", 400) if @user.account_type == "employer"

	    	matchings = Matching.where(:applicant_id => @user.id, :status => "completed").all
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
	    		job_hash[:expiry_date] = job.expiry_date
	    		job_hash[:start_time] = job.start_time
	    		job_hash[:duration] = job.duration
	    		job_array << job_hash
	    	end

	    	status 200
		    job_array.to_json
		end

		desc "mark applicant as complete"
		params do
			requires :email,		type: String
			requires :applicant_id,	type: Integer
			requires :post_id,		type: Integer
		end

		post :complete, :http_codes => [
			[401, "Unauthorised - Invalid authentication token"], 
			[400, "Bad Request - Invalid job applicant / post"],
			[200, "Mark as complete successfully"],  
			[403, "Bad Request - You have already hired this person"]  
			] do
	    	matching = Matching.where(:applicant_id => params[:applicant_id], :post_id => params[:post_id]).first
	    	
	    	error!("Bad Request - Invalid job applicant / post", 400) unless matching
	    	error!("Bad Request - You have already hired this person", 403) unless matching.status == "hired"
	    	
	    	matching.status = "completed"
	    	matching.save

	    	status 200
	    	matching.to_json
		end

		desc "offer job"
		params do
			requires :email,		type: String
			requires :applicant_id,	type: Integer
			requires :post_id,		type: Integer
		end

		post :offer, :http_codes => [
			[401, "Unauthorised - Invalid authentication token"], 
			[400, "Bad Request - Invalid job applicant / post"],
			[200, "Offer job successfully"],  
			[403, "Bad Request - You have already offered this person"] 
			] do
	    	matching = Matching.where(:applicant_id => params[:applicant_id], :post_id => params[:post_id]).first
	    	
	    	error!("Bad Request - Invalid job applicant / post", 400) unless matching
	    	error!("Bad Request - You have already offered this person", 403) unless matching.status == "pending"
	    	
	    	matching.status = "offered"
	    	matching.save

	    	status 200
	    	matching.to_json
		end

		desc "withdraw job offer"
		params do
			requires :email,		type: String
			requires :applicant_id,	type: Integer
			requires :post_id,		type: Integer
		end

		post :withdraw_offer, :http_codes => [
			[401, "Unauthorised - Invalid authentication token"], 
			[400, "Bad Request - Invalid job applicant / post"],
			[200, "Withdraw job offer successfully"]
			] do
	    	matching = Matching.where(:applicant_id => params[:applicant_id], :post_id => params[:post_id], :status => "offered").first
	    	
	    	error!("Bad Request - Invalid job applicant / post", 400) unless matching
	    	
	    	matching.status = "pending"
	    	matching.save

	    	status 200
	    	matching.to_json
		end

		desc "accept job offer"
		params do
			requires :email,		type: String
			requires :post_id,		type: Integer
		end

		post :accept, :http_codes => [
			[401, "Unauthorised - Invalid authentication token"], 
			[400, "Bad Request - Invalid job applicant / post"],
			[200, "Accept job offer successfully"] 
			] do
	    	matching = Matching.where(:applicant_id => @user.id, :post_id => params[:post_id], :status => "offered").first
	    	
	    	error!("Bad Request - Invalid job applicant / post", 400) unless matching
	    	
	    	matching.status = "hired"
	    	matching.save

	    	status 200
	    	matching.to_json
		end

		desc "get all ratings"
		params do
			requires :email,		type: String
		end

		post :accept, :http_codes => [
			[401, "Unauthorised - Invalid authentication token"], 
			[400, "Bad Request - Invalid job applicant / post"],
			[200, "Hired successfully"]  
			] do
	    	matching = Matching.where(:applicant_id => @user.id, :post_id => params[:post_id], :status => "offered").first
	    	
	    	error!("Bad Request - Invalid job applicant / post", 400) unless matching
	    	
	    	matching.status = "hired"
	    	matching.save

	    	status 200
	    	matching.to_json
		end
	end
end