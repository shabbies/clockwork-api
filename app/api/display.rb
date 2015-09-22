class Display < Grape::API
	resource :posts do	
		# GET: /api/v1/posts/all.json
		desc "List all Posts"
	    get :all, :http_codes => [200, "Get successful"]  do
	      	posts = Post.where.not(:status => ["expired", "completed"]).all
	      	return_array = Array.new
	      	posts.each do |post|
	      		expiry_date = post.expiry_date
	      		if expiry_date <= Date.today - 1
	      			matchings = Matching.where(:post_id => post.id, :status => ["hired", "completed", "reviewing"])
	      			if matchings.count != 0
	      				if matchings.where(:user_rating => nil).count != 0
	      					post.status = "reviewing"
	      				else
	      					post.status = "completed"
	      				end
	      			else
	      				post.status = "expired"
	      			end
	      			post.save
	      		else
	      			return_array << post
	      		end
	      	end
	      	status 200
	      	return_array
	    end

	    desc "search API"
	    params do
			requires :query, 		type: String
		end
	    get :search, :http_codes => [200, "Get successful"] do
	      	@posts = Post.search_by_header_and_desc(params[:query]).where.not(:status => ["completed", "expired"]).all
	      	
	      	status 200
	      	@posts.to_json
	    end

	    # POST: /api/v1/posts/get_post
		desc "retrieve a post"
		params do
			requires :post_id, type: String
		end

		get :get_post, 
		:http_codes => [
			[400, "Bad Request - The post cannot be found"],
			[200, "Post successfully retrieved"]
		] do
			post = Post.where(:id => params[:post_id]).first
			error!("Bad Request - The post cannot be found", 400) unless post

		   	status 200
		   	post.to_json
		end

##########################################################################################################################
		# API FOR DEVELOPERS
	    desc "expire post - for dev only"
	    params do
			requires :id, 		type: String
		end
	    get :dev_expire_post, :http_codes => [200, "Get successful"] do
	      	post = Post.find(params[:id])
	      	post.expiry_date = "2015-01-01"
	      	matchings = Matching.where(:post_id => post.id, :status => ["hired", "completed", "reviewing"])
  			if matchings.count != 0
  				if matchings.where(:user_rating => nil).count != 0
  					post.status = "reviewing"
  				else
  					post.status = "completed"
  				end
  			else
  				post.status = "expired"
  			end
  			post.save

  			status 200
	    end  

     	desc "re-seed data - for dev only"
	    
	    get :re_seed, :http_codes => [200, "successful"] do
	      	Notification.destroy_all
	      	Matching.destroy_all
	      	Post.destroy_all
	      	User.destroy_all

      		u1 = User.create!(email: "scsoh.2012@sis.smu.edu.sg", password: "password", password_confirmation: "password", account_type: "employer", username: "kennethsohsc", address: "Suntec City", contact_number: 98123123)
			u2 = User.create!(email: "js@smu.edu.sg", password: "password", password_confirmation: "password", account_type: "job_seeker", username: "Joan Shue", address: "Toa Payoh Central Singapore", contact_number: 91110312, good_rating: 1, neutral_rating: 0, bad_rating: 0, date_of_birth: Date.parse("1980-05-11"), gender: "F", nationality: "Singaporean")
			u3 = User.create!(email: "kssc91@hotmail.com", password: "password", password_confirmation: "password", account_type: "job_seeker", username: "shabbies", address: "Singapore", contact_number: 97907685, good_rating: 3, neutral_rating: 1, bad_rating: 2, date_of_birth: Date.parse("1991-05-20"), gender: "M", nationality: "Singaporean")
			u4 = User.create!(email: "iceicebaby@mail.com", password: "password", password_confirmation: "password", account_type: "employer", username: "IceIceBaby", contact_number: 91110312)
			u5 = User.create!(email: "iscreamstory@mail.com", password: "password", password_confirmation: "password", account_type: "employer", username: "iScreamStory", contact_number: 91110312)
			u6 = User.create!(email: "themeatloversclub@mail.com", password: "password", password_confirmation: "password", account_type: "employer", username: "TheMeatLoversClub", contact_number: 91110312)

			p1 = Post.create!(header: "Service Crew", company: "ShuKuu Izakaya", salary: 10.0, description: "Housewives, Students are welcome!", location: "Chinatown", posting_date: "2015-08-11", job_date: "2016-01-03", end_date: "2016-01-10", owner_id: u1.id, status: "applied", expiry_date: "2016-01-02", duration: 7, start_time: "11:00", end_time: "18:00", avatar_path: u1.avatar_path)
			c1 = Post.create!(header: "Weekend Dishwasher", company: "DIS Manpower Pte Ltd", salary: 9.5, description: "Job Scope - clear some stuff, load dishes into machine, unload dry store", location: "Orchard", posting_date: "2015-07-21", job_date: "2015-08-22", end_date: "2015-08-21", owner_id: u1.id, status: "completed", expiry_date: "2015-08-21", duration: 2, start_time: "11:00", end_time: "13:00", avatar_path: u1.avatar_path)
			e1 = Post.create!(header: "Cafe Service Crew", company: "TCC Manpower Pte Ltd", salary: 9.2, description: "Job Scope - Serving food and drinks, Clearing or just restaurant food runner duties, Basic Housekeeping duties", location: "Suntec City", posting_date: "2015-08-21", job_date: "2015-08-24", end_date: "2015-08-27", owner_id: u1.id, status: "expired", expiry_date: "2015-08-23", duration: 3, start_time: "11:00", end_time: "14:00", avatar_path: u1.avatar_path)
			p2 = Post.create!(header: "Poolside Bar Service", company: "Henry Almighty", salary: 8.5, description: "Can commit 5 or more days per week and for 3 MONTHS", location: "Suntec City", posting_date: "2015-08-21", job_date: "2015-09-25", end_date: "2015-09-27", owner_id: u1.id, status: "listed", expiry_date: "2015-09-24", duration: 2, start_time: "11:00", end_time: "13:00", avatar_path: u1.avatar_path)
			c2 = Post.create!(header: "Japanese Spaghetti House", company: "Japanese Spaghetti House", salary: 9.0, description: "Japanese Spaghetti House Part-time Service crew Job Scope: Greeting customers, Serving food and drinks Top up drinks Clearing empty dishes", location: "Tanjong Pagar", posting_date: "2015-08-01", job_date: "2015-09-27", end_date: "2015-09-30", owner_id: u1.id, status: "completed", expiry_date: "2015-09-26", duration: 3, start_time: "11:00", end_time: "14:00", avatar_path: u1.avatar_path)
			c3 = Post.create!(header: "Server", company: "tcchr", salary: 10.5, description: "SERVING OF FOOD AND DRINKS", location: "Sentosa", posting_date: "2015-08-01", job_date: "2015-08-27", end_date: "2015-08-28", owner_id: u1.id, status: "completed", expiry_date: "2015-08-26", duration: 2, start_time: "11:00", end_time: "13:00", avatar_path: u1.avatar_path)
			c4 = Post.create!(header: "Service Crew", company: "Cool Orchard Clubs", salary: 8.1, description: "Operating 7 F&B Restaurants, Bistros & Bars", location: "Orchard", posting_date: "2015-08-01", job_date: "2015-08-28", end_date: "2015-08-30", owner_id: u1.id, status: "completed", expiry_date: "2015-08-27", duration: 1, start_time: "11:00", end_time: "12:00", avatar_path: u1.avatar_path)
			c5 = Post.create!(header: "Service Crew", company: "Western Restaurant", salary: 8.0, description: "Taking Orders, Serving Food & Drinks & Clearing Tables", location: "Toa Payoh", posting_date: "2015-08-01", job_date: "2015-09-29", end_date: "2015-10-02", owner_id: u1.id, status: "completed", expiry_date: "2015-08-28", duration: 3, start_time: "11:00", end_time: "14:00", avatar_path: u1.avatar_path)
			c6 = Post.create!(header: "Waiter", company: "Japanese Restaurant", salary: 9.0, description: "Taking Orders, Serving Food & Drinks & Clearing Tables", location: "Buona Vista", posting_date: "2015-08-01", job_date: "2015-08-30", end_date: "2015-09-05", owner_id: u1.id, status: "completed", expiry_date: "2015-08-29", duration: 8, start_time: "11:00", end_time: "19:00", avatar_path: u1.avatar_path)
			Post.create!(header: "Hotel Cafe", company: "Studio M Hotel", salary: 12.0, description: "Responsibilities: - Greet and welcome guests, assist in taking F&B orders and ensure prompt serving", location: "Tanglin", posting_date: "2015-08-21", job_date: "2015-09-21", end_date: "2015-09-25", owner_id: u1.id, status: "expired", expiry_date: "2015-08-20", duration: 8, start_time: "11:00", end_time: "19:00", avatar_path: u1.avatar_path)
			p3 = Post.create!(header: "Restaurant Crew", company: "DIS Manpower Pte Ltd", salary: 9.0, description: "Job Scope - Serving food and drinks, Clearing or just restaurant food runner duties, Basic Housekeeping duties", location: "Boat Quay", posting_date: "2015-08-21", job_date: "2015-09-28", end_date: "2015-10-03", owner_id: u1.id, status: "applied", expiry_date: "2015-09-22", duration: 6, start_time: "11:00", end_time: "19:00", avatar_path: u1.avatar_path)
			c7 = Post.create!(header: "Cooking Crew", company: "Manpower Pte Ltd", salary: 9.0, description: "Cooking food", location: "Raffles Place", posting_date: "2015-08-01", job_date: "2015-10-26", end_date: "2015-10-27", owner_id: u1.id, status: "reviewing", expiry_date: "2015-09-25", duration: 8, start_time: "11:00", end_time: "19:00", avatar_path: u1.avatar_path)
			c8 = Post.create!(header: "Banquet Server", company: "TCCHR", salary: 8.0, description: "WE ARE HIRING !!! PT & FT Server @5* Hotel", location: "City Hall", posting_date: "2015-08-21", job_date: "2015-09-20", end_date: "2015-09-22", owner_id: u1.id, status: "reviewing", expiry_date: "2015-08-19", duration: 3, start_time: "11:00", end_time: "19:00", avatar_path: u1.avatar_path)
			c9 = Post.create!(header: "Ice Cream Scooper", company: "IceIceBaby", salary: 10.0, description: "Scooping Ice cream till you're ice baby", location: "Ang Mo Kio Ave 10", posting_date: "2015-09-14", job_date: "2015-09-18", end_date: "2015-09-20", owner_id: u4.id, status: "listed", expiry_date: "2015-09-17", duration: 3, start_time: "11:00", end_time: "21:00", avatar_path: u4.avatar_path)
			c10 = Post.create!(header: "Ice Cream Sculpter", company: "iScreamStory", salary: 8.5, description: "Sculpting ice cream! need young people", location: "East Coast Parkway", posting_date: "2015-09-14", job_date: "2015-09-19", end_date: "2015-09-21", owner_id: u5.id, status: "listed", expiry_date: "2015-09-18", duration: 3, start_time: "11:00", end_time: "21:00", avatar_path: u5.avatar_path)
			c11 = Post.create!(header: "Meat Cutter", company: "The Meat Lover's Club", salary: 10.0, description: "Cut meat, eat meat, love meat", location: "Jurong Mall", posting_date: "2015-08-14", job_date: "2015-09-10", end_date: "2015-09-11", owner_id: u6.id, status: "completed", expiry_date: "2015-09-09", duration: 2, start_time: "11:00", end_time: "21:00", avatar_path: u6.avatar_path)
			c12 = Post.create!(header: "Cooking Master", company: "Flip Flop Cookery", salary: 12.0, description: "Cooking food, being a master at it", location: "Raffles Place", posting_date: "2015-08-01", job_date: "2015-09-25", end_date: "2015-09-26", owner_id: u1.id, status: "applied", expiry_date: "2015-09-24", duration: 2, start_time: "11:00", end_time: "19:00", avatar_path: u1.avatar_path)
			c13 = Post.create!(header: "Jack of All Trades", company: "Jack's Place", salary: 9.5, description: "jacking people professionally", location: "Raffles Place", posting_date: "2015-08-01", job_date: "2015-09-26", end_date: "2015-09-27", owner_id: u1.id, status: "applied", expiry_date: "2015-09-25", duration: 2, start_time: "11:00", end_time: "19:00", avatar_path: u1.avatar_path)

			Post.create!([
			  {header: "Frozen Yogurt Server", company: "Mission Juice", salary: 10.0, description: "If you are looking to join an energetic, fun and vibrant team that offers on the job training and support, then join Mission Juice today! If you value commitment, professionalism and have a keen interest in learning and enhancing your skill set, join the Mission Juice team today! If you want to be among a group of people who want to progress together by working hard and want a place where you can excel and to find your full potential, then join the Mission Juice team today! If you have passion to serve and to make the world a happier place one juice at a time, then we want you! We want to hear from you! Full Time and Part time available!", location: "Tanjong Pagar", posting_date: "2015-08-01", job_date: "2015-09-26", end_date: "2015-09-27", owner_id: u1.id, status: "listed", expiry_date: "2015-09-25", duration: 8, start_time: "11:00", end_time: "19:00", avatar_path: u1.avatar_path},
			  {header: "Customer Service", company: "Next Door Cafe & Taverna", salary: 10.0, description: "We are seeking enthusiastic people to work with on full-time or part-time basis. Some experience in F&B service would be nice although not necessary. If you enjoy communicating with people and you are located in the East, come meet with us!", location: "Bedok", posting_date: "2015-08-11", job_date: "2015-11-02", end_date: "2015-11-05", owner_id: u1.id, status: "listed", expiry_date: "2015-01-01", duration: 8, start_time: "11:00", end_time: "19:00", avatar_path: u1.avatar_path}
			])
			Matching.create!([
			  {applicant_id: u3.id, post_id: c1.id, status: "completed", user_rating: -1, comments: "Came late left early"},
			  {applicant_id: u3.id, post_id: c2.id, status: "completed", user_rating: -1, comments: "Not very good worker"},
			  {applicant_id: u3.id, post_id: c3.id, status: "completed", user_rating: 0, comments: nil},
			  {applicant_id: u3.id, post_id: c4.id, status: "completed", user_rating: 1, comments: "Hardworking, first to work everyday"},
			  {applicant_id: u3.id, post_id: c5.id, status: "completed", user_rating: 1, comments: "Friendly person"},
			  {applicant_id: u3.id, post_id: c6.id, status: "completed", user_rating: 1, comments: "Fun to work with"},
			  {applicant_id: u3.id, post_id: c7.id, status: "hired", user_rating: nil, comments: nil},
			  {applicant_id: u3.id, post_id: c8.id, status: "reviewing", user_rating: nil, comments: nil},
			  {applicant_id: u3.id, post_id: p1.id, status: "pending", user_rating: nil, comments: nil},
			  {applicant_id: u3.id, post_id: p2.id, status: "offered", user_rating: nil, comments: nil},
			  {applicant_id: u3.id, post_id: c12.id, status: "offered", user_rating: nil, comments: nil},
			  {applicant_id: u3.id, post_id: c13.id, status: "pending", user_rating: nil, comments: nil},
			  {applicant_id: u3.id, post_id: p3.id, status: "hired", user_rating: nil, comments: nil},
			  {applicant_id: u2.id, post_id: c11.id, status: "completed", user_rating: 1, comments: "Very prompt and responsive"}
			])
  			status 200
	    end  

##########################################################################################################################
	end

	resource :users do
		params do
			requires :id, 		type: String, desc: "User ID"
		end

	    get :get_calendar_formatted_dates, :http_codes => [200, "Get successful"] do
	    	user = User.where(:id => params[:id]).first
	    	job_array = Array.new

	    	if user
		    	matchings = Matching.where(:applicant_id => user.id).where.not(:status => "completed").all

		    	matchings.each do |match|
		    		job = Post.find(match.post_id)
		    		start_date = Date.parse(job.job_date)
		    		end_date = Date.parse(job.end_date)

		    		while start_date <= end_date
		    			job_hash = Hash.new
			    		job_hash[:title] = job.header
			    		job_hash[:job_date] = start_date.to_s
			    		if match.status == "hired"
			    			job_hash[:color] = "#028482"
			    		else
			    			job_hash[:color] = "#FF6600"
			    		end
			    		job_array << job_hash
			    		start_date += 1
		    		end
		    	end
		    end
	    	job_array.to_json
		end
	end
end