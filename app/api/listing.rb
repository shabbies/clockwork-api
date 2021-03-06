class Listing < Grape::API
	before do
		token = request.headers["Authentication-Token"]
    	@user = User.find_by_email_and_authentication_token(params[:email],token)
    	error!('Unauthorised - Invalid authentication token', 401) unless @user
	end

	resource :posts do	
	    # POST: /api/v1/posts/new
	    desc "create a new post", {
			headers: {
			    "Authentication-Token" => {
			      description: "Authentication Token issued upon sign in",
			      required: true
			    }
 			}
		}
		## This takes care of parameter validation
		params do
			requires :email, 				type: String
	    requires :header, 			type: String
	    requires :salary, 			type: Float
	    requires :description, 	type: String
	    requires :location,	 		type: String
	    requires :job_date,			type: String
	    requires :end_date,			type: String
	    requires :start_time,		type: String
	    requires :end_time,			type: String
	    requires :pay_type,			type: String
	    optional :image, 				type: Rack::Multipart::UploadedFile
		end

		## This takes care of creating post
		post :new, 
		:http_codes => [
			[401, "Unauthorised - Invalid authentication token"], 
			[400, "(1)Bad Request - The job date should be after today | 
				(2)Bad Request - The end date should be after the start date | 
				(3)Bad Request - The salary should not be negative |
				(4)Bad Request - End time should be after start time
				(5)Bad Request - Post has already been created | 
				(6)Bad Request - The maximum job duration should be 7 days"],
			[200, "IGNORE NO SUCH CODE"],
			[201, "Post successfully created"],
			[403, "Unauthorised - Only employers can post a new job listing"]
		] do
				error!("Unauthorised - Only employers can post a new job listing", 403) unless @user.account_type == "employer"

				job_date = Date.parse(params[:job_date])
				end_date = Date.parse(params[:end_date])
				posting_date = Date.today
				salary = params[:salary]
				start_time = Time.parse(params[:start_time])
				end_time = Time.parse(params[:end_time])
				duration = (end_date - job_date).to_i + 1
				pay_type = params[:pay_type]

				error!("Bad Request - The job date should be after today", 400) unless job_date > posting_date
				error!("Bad Request - The end date should be after the start date", 400) if end_date < job_date
				error!("Bad Request - The salary should not be negative", 400) if salary < 0
				error!("Bad Request - End time should be after start time", 400) unless start_time < end_time
				error!("Bad Request - Post has already been created", 400) unless @user.published_jobs.where(:header => params[:header], :job_date => job_date, :location => params[:location]).count == 0
				error!("Bad Request - The maximum job duration should be 7 days", 400) if duration > 7

				post_image = params[:image]
				attachment = nil
				post_image_path = @user.avatar_path
				if post_image
					attachment = {
		        :filename => post_image[:filename],
		        :type => post_image[:type],
		        :headers => post_image[:head],
		        :tempfile => post_image[:tempfile]
		      }
		    end

		    post = Post.new({
			    header: params[:header],
			    company: @user.username,
			    salary: salary,
			    description: params[:description],
			    location: params[:location],
			    posting_date: posting_date,
			    job_date: job_date,
			    end_date: end_date,
			    expiry_date: Date.parse(params[:job_date]),
			    status: "listed",
			    start_time: params[:start_time],
			    end_time: params[:end_time],
			    duration: duration,
			    avatar_path: post_image_path,
			    pay_type: pay_type
		    })

		    post.save

		    if post_image
		    	attachment[:filename] = post.id.to_s + " image"
		    	post.post_image = ActionDispatch::Http::UploadedFile.new(attachment) if post_image
		    	post.avatar_path = post.post_image.url
		    	post.save
		    end
		    


		    @user.published_jobs << post
		    @user.save

		    status 201
		    post.to_json
		end

		# POST: /api/v1/posts/delete
		desc "deletes a post", {
			headers: {
			    "Authentication-Token" => {
			      description: "Authentication Token issued upon sign in",
			      required: true
			    }
 			}
		}
		params do
			requires :post_id, type: String
		end

		post :delete, 
		:http_codes => [
			[401, "Unauthorised - Invalid authentication token"], 
			[400, "Bad Request - The post cannot be found"],
			[200, "Post has been successfully deleted"],
			[403, "Unauthorised - Only the post owner can delete his post"]
		] do
			post = Post.where(:id => params[:post_id]).first
			error!("Bad Request - The post cannot be found", 400) unless post
			error!("Unauthorised - Only the post owner can delete his post", 403) unless post.owner_id == @user.id
		   
		   	post.destroy!

		   	status 200
		   	"Post has been successfully deleted".to_json
		end

		desc "updates a post", {
			headers: {
			    "Authentication-Token" => {
			      description: "Authentication Token issued upon sign in",
			      required: true
			    }
 			}
		}
		params do
			requires :email,				type: String
			requires :header, 			type: String
	    requires :salary, 			type: Float
	    requires :description, 	type: String
	    requires :location,	 		type: String
	    requires :post_id,			type: String
	    requires :job_date,			type: String
	  	requires :end_date,			type: String
	    requires :start_time,		type: String
	    requires :end_time,			type: String
	    requires :pay_type,			type: String
	    optional :image, 				type: Rack::Multipart::UploadedFile
		end

		post :update, 
		:http_codes => [
			[401, "Unauthorised - Invalid authentication token"], 
			[400, "(1)Bad Request - The post cannot be found | 
				(2)Bad Request - The job date should be after today | 
				(3)Bad Request - The end date should be after the start date | 
				(4)Bad Request - The salary should not be negative |
				(5)Bad Request - End time should be after start time
				(6)Bad Request - Unable to edit post once there are applicants |
				(7)Bad Request - The maximum job duration should be 7 days"],
			[200, "Returns Post Object"],
			[403, "Unauthorised - Only the post owner is allowed to edit post"]
		] do
    	post = Post.where(:id => params[:post_id]).first
    	job_date = Date.parse(params[:job_date])
			end_date = Date.parse(params[:end_date])
			posting_date = Date.today
			salary = params[:salary]
			start_time = Time.parse(params[:start_time])
			end_time = Time.parse(params[:end_time])
			duration = (end_date - job_date).to_i + 1
			pay_type = params[:pay_type]

			error!("Bad Request - The post cannot be found", 400) unless post
    	error!('Unauthorised - Only the post owner is allowed to edit post', 403) unless post.owner_id == @user.id
    	error!("Bad Request - The job date should be after today", 400) unless job_date > posting_date
			error!("Bad Request - The end date should be after the start date", 400) if end_date < job_date
			error!("Bad Request - The salary should not be negative", 400) if salary < 0
			error!("Bad Request - End time should be after start time", 400) unless start_time < end_time
			error!("Bad Request - Unable to edit post once there are applicants", 400) if Matching.where(:post_id => post.id).count > 0
			error!("Bad Request - The maximum job duration should be 7 days", 400) if duration > 7

			post_image = params[:image]
			attachment = nil
			post_image_path = post.avatar_path
			if post_image
				attachment = {
	        :filename => post.id.to_s + " image",
	        :type => post_image[:type],
	        :headers => post_image[:head],
	        :tempfile => post_image[:tempfile]
	      }
	      post.post_image = ActionDispatch::Http::UploadedFile.new(attachment)
	      post.save
	    	post_image_path = post.post_image.url
	    end

	    post.update({
	    	header: params[:header],
		    salary: salary,
		    description: params[:description],
		    location: params[:location],
		    job_date: job_date,
		    end_date: end_date,
		    expiry_date: Date.parse(params[:job_date]) - 1,
		    start_time: params[:start_time],
		    end_time: params[:end_time],
		    duration: duration,
		    pay_type: pay_type,
		    avatar_path: post_image_path
	    })

	    status 200
	    post.to_json
		end

		desc "get applicants", {
			headers: {
			    "Authentication-Token" => {
			      description: "Authentication Token issued upon sign in",
			      required: true
			    }
 			}
		}
		params do
			requires :email,		type: String
			requires :post_id,		type: Integer
		end

		post :get_applicants, 
		:http_codes => [
			[401, "Unauthorised - Invalid authentication token"], 
			[400, "Bad Request - The post cannot be found"],
			[200, "IGNORE NO SUCH CODE"],
			[403, "Unauthorised - Only owner can view applicants"],
			[401, "Returns list of applicants"]
		] do
	    	post = Post.where(:id => params[:post_id]).first

	    	error!("Bad Request - Post not found", 400) unless post
	    	error!("Unauthorised - Only owner can view applicants", 403) unless post.owner_id == @user.id
	    	
	    	applicant_array = Array.new
	    	matchings = Matching.where(:post_id => post.id, :status => "pending").all

	    	matchings.each do |match|
	    		user = User.find(match.applicant_id)
	    		merge_hash = user.score.as_json
	    		merge_hash.merge!(user.as_json)
	    		applicant_array << merge_hash
	    	end
	    	applicant_array = (applicant_array.sort_by &:good_rating).reverse

	    	status 201
	    	applicant_array.to_json
		end

		desc "get all applicants", {
			headers: {
			    "Authentication-Token" => {
			      description: "Authentication Token issued upon sign in",
			      required: true
			    }
 			}
		}
		params do
			requires :email,		type: String
			requires :post_id,		type: Integer
		end

		post :get_all_applicants, 
		:http_codes => [
			[401, "Unauthorised - Invalid authentication token"], 
			[400, "Bad Request - Post not found"],
			[200, "IGNORE NO SUCH CODE"],
			[403, "Unauthorised - Only owner can view applicants"],
			[201, "Returns a list of all applicants (regardless of status)"]
		] do
	    	post = Post.where(:id => params[:post_id]).first

	    	error!("Bad Request - Post not found", 400) unless post
	    	error!("Unauthorised - Only owner can view applicants", 403) unless post.owner_id == @user.id
	    	
	    	all_map = Hash.new
	    	applicant_array = Array.new
	    	hired_array = Array.new 	# if job expires, then hired list will be pending review
	    	reviewing_array = Array.new
	    	offered_array = Array.new
	    	completed_array = Array.new

	    	matchings = Matching.where(:post_id => post.id).all
	    	matchings.each do |match|
	    		user = User.find(match.applicant_id)
	    		user = User.find(match.applicant_id)
	    		merge_hash = user.score.as_json
	    		merge_hash.merge!(user.as_json)
	    		if match.status == "pending"
	    			applicant_array << merge_hash
	    		elsif match.status == "offered"
	    			offered_array << merge_hash
	    		elsif match.status == "hired"
	    			hired_array << merge_hash
	    		elsif match.status == "reviewing"
	    			reviewing_array << merge_hash
	    		else
	    			completed_array << merge_hash
	    		end
	    	end

	    	all_map[:pending] = applicant_array
	    	all_map[:offered] = offered_array
	    	all_map[:hired] = hired_array
	    	all_map[:reviewing] = reviewing_array
	    	all_map[:completed] = completed_array

	    	status 201
	    	all_map.to_json
		end

		desc "get hired list", {
			headers: {
			    "Authentication-Token" => {
			      description: "Authentication Token issued upon sign in",
			      required: true
			    }
 			}
		}
		params do
			requires :email,		type: String
			requires :post_id,		type: Integer
		end

		post :get_hired, 
		:http_codes => [
			[401, "Unauthorised - Invalid authentication token"], 
			[400, "Bad Request - Post not found"],
			[200, "IGNORE NO SUCH CODE"],
			[403, "Unauthorised - Only owner can view applicants"],
			[201, "Returns a list of all hired applicants"]
		] do
	    	post = Post.where(:id => params[:post_id]).first

	    	error!("Bad Request - Post not found", 400) unless post
	    	error!("Unauthorised - Only owner can view applicants", 403) unless post.owner_id == @user.id
	    	
	    	applicant_array = Array.new
	    	matchings = Matching.where(:post_id => post.id, :status => "hired").all

	    	matchings.each do |match|
	    		user = User.find(match.applicant_id)
	    		merge_hash = user.score.as_json
	    		merge_hash.merge!(user.as_json)
	    		applicant_array << merge_hash
	    	end

	    	status 201
	    	applicant_array.to_json
		end

		desc "get completed list", {
			headers: {
			    "Authentication-Token" => {
			      description: "Authentication Token issued upon sign in",
			      required: true
			    }
 			}
		}
		params do
			requires :email,		type: String
			requires :post_id,		type: Integer
		end

		post :get_completed, 
		:http_codes => [
			[401, "Unauthorised - Invalid authentication token"], 
			[400, "Bad Request - Post not found"],
			[200, "IGNORE NO SUCH CODE"],
			[403, "Unauthorised - Only owner can view applicants"],
			[201, "Returns a list of all complete matchings (with ratings)"]
		] do
	    	post = Post.where(:id => params[:post_id]).first

	    	error!("Bad Request - Post not found", 400) unless post
	    	error!("Unauthorised - Only owner can view applicants", 403) unless post.owner_id == @user.id
	    	
	    	matchings = Matching.where(:post_id => post.id, :status => ["completed", "hired", "reviewing"]).all

	    	status 201
	    	matchings.to_json
		end

		desc "rate user", {
			headers: {
			    "Authentication-Token" => {
			      description: "Authentication Token issued upon sign in",
			      required: true
			    }
 			}
		}
		params do
			requires :email,				type: String
			requires :user_feedback,		type: String
			requires :post_id,				type: Integer
		end

		post :rate, 
		:http_codes => [
			[401, "Unauthorised - Invalid authentication token"], 
			[200, "IGNORE NO SUCH CODE"],
			[201, "Rate successfully"]
		] do
			#user_ratings structure => [{user_id: int, rating: int, comment: string}]
			user_feedback_array = JSON.parse params[:user_feedback]
			user_feedback_array.each do |user_feedback|
				user_id = user_feedback["user_id"]
				rating = user_feedback["rating"]
				comment = user_feedback["comment"]
				matching = Matching.where(:post_id => params[:post_id], :applicant_id => user_id).first
				matching.user_rating = rating
				matching.comments = comment
				matching.status = "completed"
				matching.save
				retrieved_user = matching.applicant
				if rating == "-1"
					bad_rating = retrieved_user.bad_rating += 1
					retrieved_user.bad_rating = bad_rating
				elsif rating === "0"
					neutral_rating = retrieved_user.neutral_rating += 1
					retrieved_user.neutral_rating = neutral_rating
				else
					good_rating = retrieved_user.good_rating += 1
					retrieved_user.good_rating = good_rating
				end
				Notification.create!(:sender_id => @user.id, :receiver_id => user_id, :content => "#{@user.username} has just rated you for your work at #{Post.find(params[:post_id]).header}!", :avatar_path => @user.avatar_path, :post_id => params[:post_id])
				retrieved_user.save
			end

			if Matching.where(:post_id => params[:post_id], :status => ["reviewing", "hired"]).count == 0
				post = Post.find(params[:post_id])
				post.status = "completed"
				post.save
			end

			status 201
		end

		desc "get job status", {
			headers: {
			    "Authentication-Token" => {
			      description: "Authentication Token issued upon sign in",
			      required: true
			    }
 			}
		}
		params do
			requires :email,		type: String
			requires :post_id,		type: Integer
		end

		get :get_status, 
		:http_codes => [
			[401, "Unauthorised - Invalid authentication token"], 
			[201, "Returns status"]
		] do
	    	status 201
	    	return Matching.where(post_id: params[:post_id], applicant_id: @user.id).first.status
		end

		desc "check in user", {
			headers: {
			    "Authentication-Token" => {
			      description: "Authentication Token issued upon sign in",
			      required: true
			    }
 			}
		}
		params do
			requires :email,		type: String
			requires :post_id,	type: Integer
			requires :user_id,	type: Integer
		end

		post :check_in, 
		:http_codes => [
			[401, "Unauthorised - Invalid authentication token"], 
			[200, "IGNORE NO SUCH CODE"],
			[201, "check in successfully"],
			[400, "(1) No matching found | 
						 (2) Only the employer can check in"]
		] do
			matching = Matching.where(post_id: params[:post_id], status: "hired", applicant_id: params[:user_id]).first
			error!("Bad Request - Matching not found", 400) unless matching

    	error!("Unauthorised - Only the employer can check in", 400) unless matching.post.owner_id == @user.id

    	time = Time.now.in_time_zone('Singapore').strftime("%I:%M %p")
    	date = Time.now.in_time_zone('Singapore').strftime("%d-%m-%Y")

    	matching.job_timings[date]["check_in"] = time
    	matching.save

			status 201
		end

		desc "check out user", {
			headers: {
			    "Authentication-Token" => {
			      description: "Authentication Token issued upon sign in",
			      required: true
			    }
 			}
		}
		params do
			requires :email,		type: String
			requires :post_id,	type: Integer
			requires :user_id,	type: Integer
		end

		post :check_out, 
		:http_codes => [
			[401, "Unauthorised - Invalid authentication token"], 
			[200, "IGNORE NO SUCH CODE"],
			[201, "check in successfully"],
			[400, "(1) No matching found | 
						 (2) Only the employer can check out"]
		] do
			matching = Matching.where(post_id: params[:post_id], status: "hired", applicant_id: params[:user_id]).first
			error!("Bad Request - Matching not found", 400) unless matching

    	error!("Unauthorised - Only the employer can check out", 400) unless matching.post.owner_id == @user.id

    	time = Time.now.in_time_zone('Singapore').strftime("%I:%M %p")
    	date = Time.now.in_time_zone('Singapore').strftime("%d-%m-%Y")

    	matching.job_timings[date]["check_out"] = time

    	start_time = matching.job_timings[date]["check_in"]

    	time_diff = Time.now.in_time_zone('Singapore') - (Time.parse(start_time))
    	time_diff_hour = (time_diff / 3600).floor
    	time_diff_min = ((time_diff - (time_diff_hour * 3600)) / 900).floor

    	basic_salary = matching.post.salary
    	salary_type = matching.post.pay_type
    	total_salary = basic_salary
    	if salary_type == "hour"
    		total_salary = basic_salary * time_diff_hour
    		total_salary += (time_diff_min / 4) * basic_salary
    	end

    	matching.job_timings[date]["day_wage"] = total_salary
    	matching.save

			status 201
		end

		desc "update wage", {
			headers: {
			    "Authentication-Token" => {
			      description: "Authentication Token issued upon sign in",
			      required: true
			    }
 			}
		}
		params do
			requires :email,					type: String
			requires :post_id,				type: Integer
			requires :applicant_id,		type: Integer
			requires :date,						type: String
			requires :salary,					type: Float
		end

		post :update_salary, 
		:http_codes => [
			[401, "Unauthorised - Invalid authentication token"], 
			[200, "IGNORE NO SUCH CODE"],
			[201, "update successfully"],
			[400, "(1) No matching found | 
						 (2) Only the employer can update wages"]
		] do
			
			matching = Matching.where(post_id: params[:post_id], status: "hired", applicant_id: params[:applicant_id]).first
			error!("Bad Request - Matching not found", 400) unless matching

    	error!("Unauthorised - Only the employer can check in", 400) unless matching.post.owner_id == @user.id

    	matching.job_timings[params[:date]]["day_wage"] = params[:salary]


    	matching.save

			status 201
		end
	end 
end