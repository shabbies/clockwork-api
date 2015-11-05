class Account < Grape::API
	before do
		token = request.headers["Authentication-Token"]
    	@user = User.find_by_email_and_authentication_token(params[:email],token)
    	error!('Unauthorised - Invalid authentication token', 401) unless @user
	end

	resource :users do
		desc "get updated user"
		params do
			requires :email, 					type: String
		end

		post :get_updated_user, 
		:http_codes => [
			[401, "Unauthorised - Invalid authentication token"], 
			[200, "Save successful"]
		] do
			
			status 200
			@user.to_json
		end
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

		post :update, 
		:http_codes => [
			[401, "Unauthorised - Invalid authentication token"], 
			[400, "(1)Bad Request - You should be at least 15 years old | 
					(2)Bad Request - Passwords do not match |
					(3)Bad Request - Contact Number already in use"],
			[200, "Save successful"],
			[403, "Unauthorised - Old password is invalid"],
			[500, "Internal Server Error - save failed"]
		] do

			unless params[:date_of_birth].blank?
				date_of_birth = Date.parse(params[:date_of_birth])
				error!("Bad Request - You should be at least 15 years old", 400) if date_of_birth > Date.today - (15 * 365)
			end

			if params[:contact_number]
				error!("Bad Request - This contact number is already in use!", 400) if User.where(contact_number: params[:contact_number]).where.not(id: @user.id).first
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
				error!("Server Error - Save has failed, please inform the administrator", 500)
			end
		end

		desc "complete user profile"
		params do
			requires :email, 					type: String
			optional :date_of_birth, 			type: String
			optional :avatar, 					type: Rack::Multipart::UploadedFile, desc: "param name: avatar, name of file should be {:user_id}_avatar"
			optional :password,					type: String,	desc: "Only required when updating password"
			optional :password_confirmation, 	type: String,	desc: "Has to be the same as password"
			optional :old_password,				type: String, 	desc: "Only required when updating password"
			optional :address,					type: String
			optional :username,					type: String
			optional :contact_number,			type: String
			optional :gender,					type: String,	desc: "M or F"
			optional :nationality,				type: String,	desc: "Singaporean, Singapore PR or Others"
		end

		post :complete_profile, 
		:http_codes => [
			[401, "Unauthorised - Invalid authentication token"], 
			[400, "(1)Bad Request - You should be at least 15 years old || 
				(2)Bad Request - Invalid Gender: only M and F allowed ||
				(3)Bad Request - Passwords do not match | 
				(4)Bad Request - Contact Number already in use"],
			[200, "Save successful"],
			[500, "Internal Server Error - save failed"]
		] do

			unless params[:gender].blank?
				gender = params[:gender].strip.upcase
				error!("Bad Request - Invalid Gender: only M and F allowed", 400) unless gender == "M" || gender == "F"
			end
			
			unless params[:date_of_birth].blank?
				date_of_birth = Date.parse(params[:date_of_birth])
				error!("Bad Request - You should be at least 15 years old", 400) if date_of_birth > Date.today - (15 * 365)
			end

			unless params[:contact_number].blank?
				error!("Bad Request - This contact number is already in use!", 400) if User.where(contact_number: params[:contact_number]).where.not(id: @user.id).first
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

		    nationality = params[:nationality].strip.capitalize.gsub("pr", "PR") unless params[:nationality].blank?

		    @user.address = params[:address] unless params[:address].blank?
		    @user.date_of_birth = date_of_birth unless params[:date_of_birth].blank?
		    @user.username = params[:username] unless params[:username].blank?
		    @user.contact_number = params[:contact_number] unless params[:contact_number].blank?
		    @user.gender = gender unless gender.blank?
		    @user.nationality = nationality unless params[:nationality].blank?
		    if avatar
			    @user.avatar = ActionDispatch::Http::UploadedFile.new(attachment) if avatar
		    	@user.avatar_path = @user.avatar.url
		    end
		    if @user.save
		    	status 200
		    	@user.to_json
			else
				error!("Server Error - Save has failed, please inform the administrator", 500)
			end
		end

		desc "get all published jobs from employer"
		params do
		    requires :email,	type: String
		end

		post :get_jobs, 
		:http_codes => [
			[401, "Unauthorised - Invalid authentication token"], 
			[400, "Bad Request - Only employers are allowed to view their published jobs"],
			[200, "Returns array of published jobs"]
		] do
			error!("Bad Request - Only employers are allowed to view their published jobs", 400) unless @user.account_type == "employer"

		   	jobs = @user.published_jobs.order(:status)
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
	    		job_hash[:end_date] = job.end_date
	    		job_hash[:expiry_date] = job.expiry_date
	    		job_hash[:status] = job.status
	    		job_hash[:start_time] = job.start_time
	    		job_hash[:end_time] = job.end_time
	    		job_hash[:duration] = job.duration
	    		job_hash[:avatar_path] = job.avatar_path
	    		job_hash[:applicant_count] = Matching.where(:post_id => job.id).count
	    		job_hash[:pay_type] = job.pay_type
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

		post :apply, 
		:http_codes => [
			[401, "Unauthorised - Invalid authentication token"], 
			[400, "(1)Bad Request - Post not found | 
				(2)Bad Request - Only job seekers are allowed to apply for a job | 
				(3)Bad Request - You have already applied for another job that clashes with this"],
			[403, "Bad Request - User has already applied"],
			[200, "Returns post object"]
		] do
	    	post = Post.where(:id => params[:post_id]).first
	    	matching = Matching.where(:post_id => post, :applicant_id => @user.id).first

	    	#preparing notification
	    	job_title = post.header
	    	Notification.create!(:sender_id => @user.id, :receiver_id => post.owner_id, :content => "You have a new applicant for your job (#{job_title})", :avatar_path => @user.avatar_path, :post_id => post.id)

	    	clashed_matchings = Matching.where(:applicant_id => @user.id, :status => "hired").all

	    	error!("Bad Request - Post not found", 400) unless post
	    	error!("Bad Request - User has already applied", 403) if matching
	    	error!("Bad Request - Only job seekers are allowed to apply for a job", 400) if @user.account_type == "employer"

	    	if clashed_matchings
	    		clashed_matchings.each do |clashed_matching|
	    			clashed = Post.find(clashed_matching.post_id)
					if (post.job_date..post.end_date).overlaps?(clashed.job_date..clashed.end_date)
				    	error!("Bad Request - You have already applied for another job that clashes with this", 400)
				    	break;
			    	end	
	    		end
	    	end

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

		post :withdraw, 
		:http_codes => [
			[401, "Unauthorised - Invalid authentication token"], 
			[400, "(1)Bad Request - Only job seekers are allowed to withdraw from a job | 
				(2)Bad Request - Post cannot be found"],
			[200, "Returns a list of remaining user applications"]
		] do
	    	post = Post.where(:id => params[:post_id]).first
	    	account_type = @user.account_type

			error!("Bad Request - Only job seekers are allowed to withdraw from a job", 400) if account_type == "employer"
	    	error!("Bad Request - Post cannot be found.", 400) unless post

	    	matching = Matching.where(:applicant_id => @user.id, :post_id => post.id).first

	    	matching.destroy!
	    	if Matching.where(:post_id => post.id).count == 0
	    		post.status = "listed"
	    		post.save!
	    	end

	    	Notification.create!(:sender_id => @user.id, :receiver_id => post.owner_id, :content => "#{@user.username} just withdrew the application for #{post.header}", :avatar_path => @user.avatar_path, :post_id => post.id)

	    	status 200
	    	@user.jobs.to_json
		end

		desc "hire applicant"
		params do
			requires :email,		type: String
			requires :applicant_id,	type: Integer
			requires :post_id,		type: Integer
		end

		post :hire, 
		:http_codes => [
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

		post :get_applied_jobs, 
		:http_codes => [
			[401, "Unauthorised - Invalid authentication token"], 
			[400, "Bad Request - Only job seekers are allowed to view their applications"],
			[200, "Returns array of applied jobs"]
		] do
			error!("Bad Request - Only job seekers are allowed to view their applications", 400) if @user.account_type == "employer"

	    	matchings = Matching.where(:applicant_id => @user.id).order(:status).all
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
	    		job_hash[:end_date] = job.end_date
	    		job_hash[:status] = matching.status
	    		job_hash[:expiry_date] = job.expiry_date
	    		job_hash[:start_time] = job.start_time
	    		job_hash[:end_time] = job.end_time	
	    		job_hash[:duration] = job.duration
	    		job_hash[:rating] = matching.user_rating
	    		job_hash[:comment] = matching.comments
	    		job_hash[:avatar_path] = job.avatar_path
	    		job_hash[:pay_type] = job.pay_type
	    		job_array << job_hash
	    	end

	    	status 200
		    job_array.to_json
		end

		desc "get all completed jobs from user"
		params do
		    requires :email,	type: String
		end

		post :get_completed_jobs, 
		:http_codes => [
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
	    		job_hash[:rating] = matching.user_rating
	    		job_hash[:comments] = matching.comments
	    		job_hash[:avatar_path] = job.avatar_path
	    		job_hash[:pay_type] = job.pay_type
	    		job_array << job_hash
	    	end

	    	status 200
		    job_array.to_json
		end

		# ##### REMOVED DUE TO LACK OF NEED #########
		# desc "mark applicant as complete"
		# params do
		# 	requires :email,		type: String
		# 	requires :applicant_id,	type: Integer
		# 	requires :post_id,		type: Integer
		# end

		# post :complete, 
		# :http_codes => [
		# 	[401, "Unauthorised - Invalid authentication token"], 
		# 	[400, "Bad Request - Invalid job applicant / post"],
		# 	[200, "Mark as complete successfully"],  
		# 	[403, "Bad Request - You have already hired this person"]  
		# ] do
	 #    	matching = Matching.where(:applicant_id => params[:applicant_id], :post_id => params[:post_id]).first
	    	
	 #    	error!("Bad Request - Invalid job applicant / post", 400) unless matching
	 #    	error!("Bad Request - You have already hired this person", 403) unless matching.status == "hired"
	    	
	 #    	matching.status = "reviewing"
	 #    	matching.save

	 #    	status 200
	 #    	matching.to_json
		# end

		desc "offer job"
		params do
			requires :email,		type: String
			requires :applicant_id,	type: Integer
			requires :post_id,		type: Integer
		end

		post :offer, 
		:http_codes => [
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

	    	Notification.create!(:sender_id => @user.id, :receiver_id => params[:applicant_id], :content => "#{@user.username} has offered you a job for #{Post.find(params[:post_id]).header}", :avatar_path => @user.avatar_path, :post_id => params[:post_id])

	    	status 200
	    	matching.to_json
		end

		desc "offer all job"
		params do
			requires :email,			type: String
			requires :applicant_ids,	type: String
			requires :post_id,			type: Integer
		end

		post :offer_all, 
		:http_codes => [
			[401, "Unauthorised - Invalid authentication token"], 
			[200, "Offer job successfully"],  
			[403, "Bad Request - You have already offered this person"] 
		] do

			applicant_array = JSON.parse(params[:applicant_ids])

			Matching.transaction do
				applicant_array.each do |applicant_id|
					matching = Matching.find_by_applicant_id_and_post_id(applicant_id, params[:post_id])
					Notification.create!(:sender_id => @user.id, :receiver_id => applicant_id, :content => "#{@user.username} has offered you a job for #{Post.find(params[:post_id]).header}", :avatar_path => @user.avatar_path, :post_id => params[:post_id])
					error!("Bad Request - You have already offered this person", 403) unless matching.status == "pending"
					matching.status = "offered"
	    			matching.save
				end
			end
	    	status 200
		end

		desc "withdraw job offer"
		params do
			requires :email,		type: String
			requires :applicant_id,	type: Integer
			requires :post_id,		type: Integer
		end

		post :withdraw_offer, 
		:http_codes => [
			[401, "Unauthorised - Invalid authentication token"], 
			[400, "Bad Request - Invalid job applicant / post"],
			[200, "Withdraw job offer successfully"]
		] do
	    	matching = Matching.where(:applicant_id => params[:applicant_id], :post_id => params[:post_id], :status => "offered").first
	    	
	    	error!("Bad Request - Invalid job applicant / post", 400) unless matching
	    	
	    	Notification.create!(:sender_id => @user.id, :receiver_id => params[:applicant_id], :content => "#{@user.username} has withdrew the job offer for #{Post.find(params[:post_id]).header}", :avatar_path => @user.avatar_path, :post_id => params[:post_id])
					
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

		post :accept, 
		:http_codes => [
			[401, "Unauthorised - Invalid authentication token"], 
			[400, "Bad Request - Invalid job applicant / post"],
			[200, "Accept job offer successfully"],
			[201, "Accept job offer successfully with posts dropped (returns names of posts dropped in format [name1, name2])"]
		] do
	    	matching = Matching.where(:applicant_id => @user.id, :post_id => params[:post_id], :status => "offered").first
	    	post = Post.find(params[:post_id])
	    	error!("Bad Request - Invalid job applicant / post", 400) unless matching
	    	clashed_matchings = Matching.where(:applicant_id => @user.id, :status => ["offered", "pending"]).all

	    	Notification.create!(:sender_id => @user.id, :receiver_id => post.owner_id, :content => "#{@user.username} has accepted your a job offer!", :avatar_path => @user.avatar_path, :post_id => post.id)

	    	if clashed_matchings
	    		return_array = Array.new
	    		clashed_matchings.each do |clashed_matching|
	    			clashed = Post.find(clashed_matching.post_id)
	    			next if clashed == post
					if (post.job_date..post.end_date).overlaps?(clashed.job_date..clashed.end_date)
				    	clashed_matching.destroy!

				    	if Matching.where(:post_id => clashed.id).count == 0
				    		clashed.status = "listed"
				    		clashed.save
				    	end
				    	formatted_return = clashed.id.to_s + "|" + clashed.header
				    	return_array << formatted_return
			    	end	
	    		end

	    		matching.status = "hired"
	    		matching.save

	    		status 201
	    		return_array.to_json

	    	else
		    	matching.status = "hired"
		    	matching.save

		    	status 200
		    	matching.to_json
	    	end
		end

		desc "get unread notifications"
		params do
			requires :email,		type: String
		end

		post :get_unread_notifications, 
		:http_codes => [
			[401, "Unauthorised - Invalid authentication token"], 
			[200, "Notifications returned successfully"] 
		] do
	    	notifications = Notification.where(:receiver_id => @user.id, :status => "unread").all;
	    	
	    	status 200
	    	notifications.to_json
		end

		desc "get all notifications"
		params do
			requires :email,		type: String
		end

		post :get_all_notifications, 
		:http_codes => [
			[401, "Unauthorised - Invalid authentication token"], 
			[200, "Notifications returned successfully"] 
		] do
	    	notifications = @user.received_notifications.where(status: "unread").all
	    	read_notifications = @user.received_notifications.where(status: "read").first(100)
	    	notifications += read_notifications
	    	notifications.reverse!

	    	status 200
	    	notifications.to_json
		end

		desc "read passed notifications"
		params do
			requires :email,				type: String
			requires :notification_ids, 	type: String, desc: "format - 'id1,id2,id3'"
		end

		post :read_notifications, 
		:http_codes => [
			[401, "Unauthorised - Invalid authentication token"], 
			[200, "Notifications read successfully"] 
		] do
	    	notification_ids = params[:notification_ids].split(",")
	    	notifications = Notification.where(id: notification_ids).all
	    	notifications.each do |notification|
	    		notification.status = "read"
	    		notification.save!
	    	end

	    	status 200
		end

		desc "send confirmation email"
		params do
			requires :email,				type: String
		end

		post :send_confirmation_email, 
		:http_codes => [
			[401, "Unauthorised - Invalid authentication token"], 
			[200, "email sent successfully"] 
		] do
	    	@user.send_confirmation_instructions

	    	status 200
		end

		desc "get obtained badges"
		params do
			requires :email,		type: String
		end

		post :get_badges, 
		:http_codes => [
			[401, "Unauthorised - Invalid authentication token"], 
			[200, "Notifications returned successfully"] 
		] do
	    	user_badges = @user.obtained_badges
	    	badges = Array.new

	    	user_badges.each do |badge_id|
	    		badge = Badge.where(badge_id: badge_id).first
	    		if badge
	    			inner_hash = Hash.new
	    			inner_hash["name"] = badge.name
	    			inner_hash["criteria"] = badge.criteria
	    			inner_hash["badge_id"] = badge_id
	    			inner_hash["badge_image_link"] = "https://s3-ap-southeast-1.amazonaws.com/media.clockworksmu.herokuapp.com/app/public/assets/badges/#{badge_id}_done.png"
	    			badges << inner_hash
	    		end
	    	end

	    	status 200
	    	badges.to_json
		end
	end
end