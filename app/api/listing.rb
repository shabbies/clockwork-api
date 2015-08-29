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
			p expiry_date

			error!("Bad Request - The job date should be after today", 400) if job_date < posting_date
			error!("Bad Request - The expiry date should be before the job date", 400) if job_date > expiry_date
			error!("Bad Request - The salary should not be negative", 400) if salary < 0

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
			    duration: params[:duration]
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
		end
		post :update do
	    	post = Post.where(:id => params[:post_id]).first
	    	job_date = Date.parse(params[:job_date])
	    	salary = params[:salary]

			error!("Bad Request - The post cannot be found", 400) unless post
			error!("Bad Request - The job date should be after today", 400) if job_date < Date.today
	    	error!('Unauthorised - Only the post owner is allowed to edit post', 403) unless post.owner_id == @user.id
	    	error!("Bad Request - The salary should not be negative", 400) if salary < 0

		    post.update({
		    	header: params[:header],
			    salary: salary,
			    description: params[:description],
			    location: params[:location],
			    job_date: job_date,
			    expiry_date: job_date - 1,
			    start_time: params[:start_time],
			    duration: params[:duration]
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
	end 
end