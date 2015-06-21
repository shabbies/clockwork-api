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
	    	desc "List all Posts"
		 
		    get do
		      	Post.all
		    end

		    # POST: /api/v1/posts.json -d ""
		    desc "create a new employee"
			## This takes care of parameter validation
			params do
			  requires :header, 		type: String
			  requires :company, 		type: String
			  requires :salary, 		type: Integer
			  requires :description, 	type: Text
			  requires :location, 		type: String
			end
			## This takes care of creating post
			post do
			  Post.create!({
			    header: params[:header],
			    company: params[:company],
			    salary: params[:salary],
			    description: params[:description],
			    location: params[:location],
			    posting_date: Date.now
			    job_date: Date.now
			  })
			end
	    end
    end
end