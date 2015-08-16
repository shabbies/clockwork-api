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
		    requires :salary, 		type: Integer
		    requires :description, 	type: String
		    requires :location,	 	type: String
		    requires :job_date,		type: String
		end

		## This takes care of creating post
		post :new do
			error!("Unauthorised - Only employers can post a new job listing", 403) unless @user.account_type == "employer"

			job_date = Date.parse(params[:job_date])
			posting_date = Date.today

			error!("Bad Request - The job date should be after today", 400) if job_date < posting_date

		    post = Post.create!({
			    header: params[:header],
			    company: @user.username,
			    salary: params[:salary],
			    description: params[:description],
			    location: params[:location],
			    posting_date: posting_date,
			    job_date: job_date,
			    status: "listed"
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
		    requires :salary, 		type: Integer
		    requires :description, 	type: String
		    requires :location,	 	type: String
		    requires :id,			type: String
		    requires :job_date,		type: String
		end
		post :update do
	    	post = Post.find(params[:id])
	    	error!('Unauthorized - Only owner allowed to edit post', 401) unless post.owner == @user

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
	    	job = Post.find(params[:job_id])
	    	error!("Post not found", 422) unless job
	    	error!("Unauthorized - Only owner can view applicants", 400) unless job.owner == @user
	    	
	    	job.applicants.to_json
		end

		desc "get hired list"
		params do
			requires :email,		type: String
			requires :job_id,		type: Integer
		end

		post :get_hired do
	    	job = Post.find(params[:job_id])
	    	error!("Post not found", 422) unless job
	    	error!("Unauthorized - Only owner can view applicants", 400) unless job.owner == @user
	    	
	    	job.hired.to_json
		end
	end 
end