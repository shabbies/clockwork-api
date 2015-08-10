module Employee
  	class Data < Grape::API 

	    resource :employee_data do
		    desc "List all Employee"
		 
		    get do
		      	EmpDatum.all
		    end

		  	desc "create a new employee"
			## This takes care of parameter validation
			params do
			  requires :name, type: String
			  requires :address, type:String
			  requires :age, type:Integer
			end
			## This takes care of creating employee
			post do
			  EmpDatum.create!({
			    name:params[:name],
			    address:params[:address],
			    age:params[:age]
			  })
			end

			# app/api/employee/data.rb
	 
			desc "delete an employee"
			params do
			  	requires :id, type: String
			end
			delete ':id' do
			  EmpDatum.find(params[:id]).destroy!
			end

			# app/api/employee/data.rb
	 
			desc "update an employee address"
			params do
			  requires :id, type: String
			  requires :address, type:String
			end
			put ':id' do
			  EmpDatum.find(params[:id]).update({
			    address:params[:address]
			  })
			end
	    end	 

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
				    job_date: Date.parse(params[:job_date])
			    })
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
				requires :header, 		type: :string
			    requires :company, 		type: :string
			    requires :salary, 		type: :integer
			    requires :description, 	type: :text
			    requires :location,	 	type: :string
			    requires :id,			type: :string
			end
			post :update do
			    post = Post.find(params[:id]).update({
			    	header: params[:header],
				    company: params[:company],
				    salary: params[:salary],
				    description: params[:description],
				    location: params[:location]
			    })
			    { 
			    	message: "post is successfully updated",
			    	status: 200,
			    	post_id: post.id
			    }
			end
	    end 
    end
end