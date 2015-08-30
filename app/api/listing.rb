class Listing < Grape::API
	before do
		token = request.headers["Authentication-Token"]
    	@user = User.find_by_email_and_authentication_token(params[:email],token)
    	error!('Unauthorised - Invalid authentication token', 401) unless @user
	end

	resource :posts do	
	    # POST: /api/v1/posts/new
	    desc "create a new post"
		## This takes care of parameter validation
		params do
			requires :email, 		type: String
		    requires :header, 		type: String
		    requires :salary, 		type: Float
		    requires :description, 	type: String
		    requires :location,	 	type: String
		    requires :job_date,		type: String
		    requires :expiry_date,	type: String
		    requires :start_time,	type: String
		    requires :duration,		type: Integer
		end

		## This takes care of creating post
		post :new do
			error!("Unauthorised - Only employers can post a new job listing", 403) unless @user.account_type == "employer"

			job_date = Date.parse(params[:job_date])
			posting_date = Date.today
			expiry_date = Date.parse(params[:expiry_date])
			salary = params[:salary]
			duration = params[:duration]

			error!("Bad Request - The job date should be after today", 400) if job_date < posting_date
			error!("Bad Request - The expiry date should be before the job date", 400) if job_date < expiry_date
			error!("Bad Request - The expiry date should be after today", 400) if job_date < posting_date
			error!("Bad Request - The salary should not be negative", 400) if salary < 0
			error!("Bad Request - The duration should not be negative", 400) if duration < 0

		    post = Post.create!({
			    header: params[:header],
			    company: @user.username,
			    salary: salary,
			    description: params[:description],
			    location: params[:location],
			    posting_date: posting_date,
			    job_date: job_date,
			    expiry_date: expiry_date,
			    status: "listed",
			    start_time: params[:start_time],
			    duration: duration
		    })
		    @user.published_jobs << post
		    @user.save

		    status 201
		    post.to_json
		end

		# POST: /api/v1/posts/delete
		desc "deletes a post"
		params do
			requires :post_id, type: String
		end

		post :delete do
			post = Post.where(:id => params[:post_id]).first
			error!("Bad Request - The post cannot be found", 400) unless post
			error!("Unauthorised - Only the post owner can delete his post", 403) unless post.owner_id == @user.id
		   
		   	post.destroy!

		   	status 200
		   	"Post has been successfully deleted".to_json
		end

		desc "updates a post"
		params do
			requires :email,		type: String
			requires :header, 		type: String
		    requires :salary, 		type: Float
		    requires :description, 	type: String
		    requires :location,	 	type: String
		    requires :post_id,		type: String
		    requires :job_date,		type: String
		    requires :start_time,	type: String
		    requires :duration, 	type: Integer
		    requires :expiry_date,	type: String
		end
		post :update do
	    	post = Post.where(:id => params[:post_id]).first
	    	job_date = Date.parse(params[:job_date])
	    	expiry_date = Date.parse(params[:expiry_date])
	    	salary = params[:salary]
	    	duration = params[:duration]

			error!("Bad Request - The post cannot be found", 400) unless post
			error!("Bad Request - The job date should be after today", 400) if job_date < Date.today
			error!("Bad Request - The expiry date should be before the job date", 400) if job_date < expiry_date
			error!("Bad Request - The expiry date should be after today", 400) if job_date < Date.today
	    	error!('Unauthorised - Only the post owner is allowed to edit post', 403) unless post.owner_id == @user.id
	    	error!("Bad Request - The salary should not be negative", 400) if salary < 0
			error!("Bad Request - The duration should not be negative", 400) if duration < 0

		    post.update({
		    	header: params[:header],
			    salary: salary,
			    description: params[:description],
			    location: params[:location],
			    job_date: job_date,
			    expiry_date: expiry_date,
			    start_time: params[:start_time],
			    duration: duration
		    })

		    status 200
		    post.to_json
		end

		desc "get applicants"
		params do
			requires :email,		type: String
			requires :post_id,		type: Integer
		end

		post :get_applicants do
	    	post = Post.where(:id => params[:post_id]).first

	    	error!("Bad Request - Post not found", 400) unless post
	    	error!("Unauthorised - Only owner can view applicants", 403) unless post.owner_id == @user.id
	    	
	    	applicant_array = Array.new
	    	matchings = Matching.where(:post_id => post.id, :status => "pending").all

	    	matchings.each do |match|
	    		user = User.find(match.applicant_id)
	    		applicant_array << user
	    	end

	    	status 201
	    	applicant_array.to_json
		end

		desc "get all applicants"
		params do
			requires :email,		type: String
			requires :post_id,		type: Integer
		end

		post :get_all_applicants do
	    	post = Post.where(:id => params[:post_id]).first

	    	error!("Bad Request - Post not found", 400) unless post
	    	error!("Unauthorised - Only owner can view applicants", 403) unless post.owner_id == @user.id
	    	
	    	all_map = Hash.new
	    	applicant_array = Array.new
	    	hired_array = Array.new
	    	offered_array = Array.new
	    	completed_array = Array.new

	    	matchings = Matching.where(:post_id => post.id).all
	    	matchings.each do |match|
	    		user = User.find(match.applicant_id)
	    		if match.status == "pending"
	    			applicant_array << user
	    		elsif match.status == "offered"
	    			offered_array << user
	    		elsif match.status == "hired"
	    			hired_array << user
	    		else
	    			completed_array << user
	    		end
	    	end

	    	all_map[:pending] = applicant_array
	    	all_map[:offered] = offered_array
	    	all_map[:hired] = hired_array
	    	all_map[:completed] = completed_array

	    	status 201
	    	all_map.to_json
		end

		desc "get hired list"
		params do
			requires :email,		type: String
			requires :post_id,		type: Integer
		end

		post :get_hired do
	    	post = Post.where(:id => params[:post_id]).first

	    	error!("Bad Request - Post not found", 400) unless post
	    	error!("Unauthorised - Only owner can view applicants", 403) unless post.owner_id == @user.id
	    	
	    	applicant_array = Array.new
	    	matchings = Matching.where(:post_id => post.id, :status => "hired").all

	    	matchings.each do |match|
	    		user = User.find(match.applicant_id)
	    		applicant_array << user
	    	end

	    	status 201
	    	applicant_array.to_json
		end

		desc "rate user"
		params do
			requires :email,				type: String
			requires :user_feedback,		type: String
			requires :post_id,				type: Integer
		end

		post :rate do
			#user_ratings structure => [{user_id: int, rating: int, comment: string}]
			user_feedback_array = JSON.parse params[:user_feedback]
			user_feedback_array.each do |user_feedback_json|
				puts user_feedback_json
				user_feedback_json.is_a? String
				user_feedback_json.is_a? Hash

				user_feedback = JSON.parse(user_feedback_json)
				user_id = user_feedback[:user_id]
				rating = user_feedback[:rating]
				comment = user_feedback[:comment]
				matching = Matching.where(:post_id => params[:post_id], :applicant_id => user_id).first
				matching.user_rating = rating
				matching.comments = comment
				matching.save
			end

			status 201
		end
	end 
end