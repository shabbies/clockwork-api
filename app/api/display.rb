class Display < Grape::API
	resource :posts do	
		# GET: /api/v1/posts/all.json
		desc "List all Posts"
		params do
			optional :user_id,	type: Integer
		end
	    get :all, :http_codes => [200, "Get successful"]  do
	    	user = User.where(:id => params[:user_id]).first
	      	posts = (user) ? Post.near(user.address, 99999999999).where.not(:status => ["expired", "completed"]).all : Post.where.not(:status => ["expired", "completed"]).all
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
		  				Notification.create!(:sender_id => post.owner_id, :receiver_id => post.owner_id, :content => "Your post #{post.header} has expired!", :avatar_path => post.avatar_path, :post_id => post.id)
		  				remaining_applicants = Matching.where(:post_id => post.id).where.not(:status => ["hired", "completed", "reviewing"])
		  				remaining_applicants.each do |applicant|
		  					Notification.create!(:sender_id => post.owner_id, :receiver_id => applicant.applicant_id, :content => "Your application for #{post.header} has expired!", :avatar_path => post.avatar_path, :post_id => post.id)
		  				end
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
	      	@posts = Post.search_by_header_and_desc(params[:query]).where.not(:status => ["completed", "expired", "reviewing"]).all
	      	
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
  				Notification.create!(:sender_id => post.owner_id, :receiver_id => post.owner_id, :content => "Your post #{post.header} has expired!", :avatar_path => post.avatar_path, :post_id => post.id)
  				remaining_applicants = Matching.where(:post_id => post.id).where.not(:status => ["hired", "completed", "reviewing"])
  				remaining_applicants.each do |applicant|
  					Notification.create!(:sender_id => post.owner_id, :receiver_id => applicant.applicant_id, :content => "Your application for #{post.header} has expired!", :avatar_path => post.avatar_path, :post_id => post.id)
  				end
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
	      	Score.destroy_all
	      	Badge.destroy_all
	      	QuestionHistory.destroy_all
	      	Question.destroy_all

      		u1 = User.create!(email: "scsoh.2012@sis.smu.edu.sg", password: "password", password_confirmation: "password", account_type: "employer", username: "kennethsohsc", address: "Suntec City", contact_number: 98123123, latitude: 1.2959623, longitude: 103.8579517, referral_id: User.generate_referral_id)
			u2 = User.create!(email: "js@smu.edu.sg", password: "password", password_confirmation: "password", account_type: "job_seeker", username: "Joan Shue", address: "Toa Payoh Central Singapore", contact_number: 91110312, good_rating: 1, neutral_rating: 0, bad_rating: 0, date_of_birth: Date.parse("1980-05-11"), gender: "F", nationality: "Singaporean", latitude: 1.3341389, longitude: 103.8491111, referral_id: User.generate_referral_id, obtained_badges: ["newbie"])
			u3 = User.create!(email: "kssc91@hotmail.com", password: "password", password_confirmation: "password", account_type: "job_seeker", username: "shabbies", address: "Singapore", contact_number: 97907685, good_rating: 3, neutral_rating: 1, bad_rating: 2, date_of_birth: Date.parse("1991-05-20"), gender: "M", nationality: "Singaporean", latitude: 1.352083, longitude: 103.819836, referral_id: User.generate_referral_id, obtained_badges: ["newbie", "superuser"])
			u4 = User.create!(email: "iceicebaby@mail.com", password: "password", password_confirmation: "password", account_type: "employer", username: "IceIceBaby", contact_number: 98871236, referral_id: User.generate_referral_id)
			u5 = User.create!(email: "iscreamstory@mail.com", password: "password", password_confirmation: "password", account_type: "employer", username: "iScreamStory", contact_number: 81920471, referral_id: User.generate_referral_id)
			u6 = User.create!(email: "themeatloversclub@mail.com", password: "password", password_confirmation: "password", account_type: "employer", username: "TheMeatLoversClub", contact_number: 89018432, referral_id: User.generate_referral_id)
			hoi = User.create!(email: "gerald@gmail.com", password: "password", password_confirmation: "password", account_type: "job_seeker", username: "Gerald Lim", address: "Toa Payoh Central Singapore", contact_number: 81231412, good_rating: 2, neutral_rating: 1, bad_rating: 0, date_of_birth: Date.parse("1980-05-11"), gender: "M", nationality: "Singaporean", avatar_path: "https://s3-ap-southeast-1.amazonaws.com/media.clockworksmu.herokuapp.com/app/public/assets/logos/Gerald.jpg", latitude: 1.3341389, longitude: 103.8491111, referral_id: User.generate_referral_id, obtained_badges: ["newbie"])

			today = Date.today

			p1 = Post.create!(header: "Service Staff", company: "Fourty Hands", salary: 10.0, description: "Housewives, Students are welcome! SEED-DEMO", location: "448 Ang Mo Kio Ave 10, 560448", posting_date: "2015-08-11", job_date: "2016-01-03", end_date: "2016-01-09", owner_id: u1.id, status: "applied", expiry_date: "2016-01-02", duration: 7, start_time: "11:00", end_time: "18:00", avatar_path: "https://s3-ap-southeast-1.amazonaws.com/media.clockworksmu.herokuapp.com/app/public/assets/logos/14-fortyhands-logo.jpeg", latitude: 1.367516, longitude: 103.856308)
			c1 = Post.create!(header: "Weekend Dishwasher", company: "Artistry", salary: 9.5, description: "Job Scope - clear some stuff, load dishes into machine, unload dry store SEED-DEMO", location: "452 Ang Mo Kio Ave 10, Singapore 560452", posting_date: "2015-07-21", job_date: "2015-08-22", end_date: "2015-08-21", owner_id: u1.id, status: "completed", expiry_date: "2015-08-21", duration: 2, start_time: "11:00", end_time: "13:00", avatar_path: "https://s3-ap-southeast-1.amazonaws.com/media.clockworksmu.herokuapp.com/app/public/assets/logos/Artistry+Cafe.png", latitude: 1.3688949, longitude: 103.856313)
			e1 = Post.create!(header: "Cafe Service Crew", company: "Crossings Cafe", salary: 9.2, description: "Job Scope - Serving food and drinks, Clearing or just restaurant food runner duties, Basic Housekeeping duties SEED-DEMO", location: "9 Bishan Place, #04-03, Junction 8, Singapore 579837", posting_date: "2015-08-21", job_date: "2015-08-24", end_date: "2015-08-27", owner_id: u1.id, status: "expired", expiry_date: "2015-08-23", duration: 3, start_time: "11:00", end_time: "14:00", avatar_path: "https://s3-ap-southeast-1.amazonaws.com/media.clockworksmu.herokuapp.com/app/public/assets/logos/Crossings.png", latitude: 1.3604421, longitude: 103.8522322)
			p2 = Post.create!(header: "Poolside Bar Service", company: "Crossings Cafe", salary: 8.5, description: "Can commit 5 or more days per week and for 3 MONTHS SEED-DEMO", location: "5 Bishan Street 14, Singapore 579783", posting_date: "2015-08-21", job_date: today+31, end_date: today+32, owner_id: u1.id, status: "applied", expiry_date: today+35, duration: 2, start_time: "11:00", end_time: "13:00", avatar_path: "https://s3-ap-southeast-1.amazonaws.com/media.clockworksmu.herokuapp.com/app/public/assets/logos/Crossings.png", latitude: 1.3552446, longitude: 103.8508052)
			c2 = Post.create!(header: "Japanese Server", company: "Flock Cafe", salary: 9.0, description: "Japanese Spaghetti House Part-time Service crew Job Scope: Greeting customers, Serving food and drinks Top up drinks Clearing empty dishes SEED-DEMO", location: "9 Bishan Street 22, 579767", posting_date: "2015-08-01", job_date: "2015-09-27", end_date: "2015-09-30", owner_id: u1.id, status: "completed", expiry_date: "2015-09-26", duration: 3, start_time: "11:00", end_time: "14:00", avatar_path: "https://s3-ap-southeast-1.amazonaws.com/media.clockworksmu.herokuapp.com/app/public/assets/logos/Flock-Cafe-06.jpg", latitude: 1.355193, longitude: 103.846228)
			c3 = Post.create!(header: "Server", company: "Loaves Me", salary: 10.5, description: "SERVING OF FOOD AND DRINKS SEED-DEMO", location: "1 Raffles Institution Ln, 575954", posting_date: "2015-08-01", job_date: "2015-08-27", end_date: "2015-08-28", owner_id: u1.id, status: "completed", expiry_date: "2015-08-26", duration: 2, start_time: "11:00", end_time: "13:00", avatar_path: "https://s3-ap-southeast-1.amazonaws.com/media.clockworksmu.herokuapp.com/app/public/assets/logos/Loaves+Me.jpg", latitude: 1.3466384, longitude: 103.8432556)
			c4 = Post.create!(header: "Crew", company: "Pacamara", salary: 8.1, description: "Operating 7 F&B Restaurants, Bistros & Bars SEED-DEMO", location: "260 Orchard Rd, 238855", posting_date: "2015-08-01", job_date: "2015-08-28", end_date: "2015-08-30", owner_id: u1.id, status: "completed", expiry_date: "2015-08-27", duration: 1, start_time: "11:00", end_time: "12:00", avatar_path: "https://s3-ap-southeast-1.amazonaws.com/media.clockworksmu.herokuapp.com/app/public/assets/logos/Pacamara.png", latitude: 1.3029619, longitude: 103.8371889)
			c5 = Post.create!(header: "Restaurant Service Crew", company: "Plain Vanilla", salary: 8.0, description: "Taking Orders, Serving Food & Drinks & Clearing Tables SEED-DEMO", location: "37 Emerald Hill Rd, 229313", posting_date: "2015-08-01", job_date: "2015-09-29", end_date: "2015-10-02", owner_id: u1.id, status: "completed", expiry_date: "2015-08-28", duration: 3, start_time: "11:00", end_time: "14:00", avatar_path: "https://s3-ap-southeast-1.amazonaws.com/media.clockworksmu.herokuapp.com/app/public/assets/logos/Plain+Vanilla.jpeg", latitude: 1.302847, longitude: 103.838528)
			c6 = Post.create!(header: "Waiter", company: "The Assembly Ground", salary: 9.0, description: "Taking Orders, Serving Food & Drinks & Clearing Tables SEED-DEMO", location: "181 Orchard Rd, 238896", posting_date: "2015-08-01", job_date: "2015-08-30", end_date: "2015-09-05", owner_id: u1.id, status: "completed", expiry_date: "2015-08-29", duration: 8, start_time: "11:00", end_time: "19:00", avatar_path: "https://s3-ap-southeast-1.amazonaws.com/media.clockworksmu.herokuapp.com/app/public/assets/logos/The+Assembly+Ground.jpg", latitude: 1.3006313, longitude: 103.8397382)
			Post.create!(header: "Hotel Cafe", company: "The Assembly Ground", salary: 12.0, description: "Responsibilities: - Greet and welcome guests, assist in taking F&B orders and ensure prompt serving SEED-DEMO", location: "113 Somerset Rd, 238165", posting_date: "2015-08-21", job_date: "2015-09-21", end_date: "2015-09-25", owner_id: u1.id, status: "expired", expiry_date: "2015-08-20", duration: 8, start_time: "11:00", end_time: "19:00", avatar_path: "https://s3-ap-southeast-1.amazonaws.com/media.clockworksmu.herokuapp.com/app/public/assets/logos/The+Assembly+Ground.jpg", latitude: 1.3005397, longitude: 103.8367624)
			p3 = Post.create!(header: "Restaurant Crew", company: "Tiong Bahru Bakery", salary: 9.0, description: "Job Scope - Serving food and drinks, Clearing or just restaurant food runner duties, Basic Housekeeping duties SEED-DEMO", location: "11 Canning Walk, 178881", posting_date: "2015-08-21", job_date: today+30, end_date: today+35, owner_id: u1.id, status: "applied", expiry_date: today+5, duration: 6, start_time: "11:00", end_time: "19:00", avatar_path: "https://s3-ap-southeast-1.amazonaws.com/media.clockworksmu.herokuapp.com/app/public/assets/logos/Tiong+Bahru+Bakery+2.jpg", latitude: 1.295913, longitude: 103.845489)
			c7 = Post.create!(header: "Cooking Crew", company: "Tiong Bahru Bakery", salary: 9.0, description: "Cooking food SEED-DEMO", location: "50 Nanyang Ave, 639798", posting_date: "2015-08-01", job_date: "2015-10-26", end_date: "2015-10-27", owner_id: u1.id, status: "reviewing", expiry_date: "2015-09-25", duration: 8, start_time: "11:00", end_time: "19:00", avatar_path: "https://s3-ap-southeast-1.amazonaws.com/media.clockworksmu.herokuapp.com/app/public/assets/logos/Tiong+Bahru+Bakery+2.jpg", latitude: 1.347681, longitude: 103.6827797)
			c8 = Post.create!(header: "Banquet Server", company: "Assembly Cafe", salary: 8.0, description: "WE ARE HIRING !!! PT & FT Server @5* Hotel SEED-DEMO", location: "31 Jurong West Street 63, 648310", posting_date: "2015-08-21", job_date: "2015-09-20", end_date: "2015-09-22", owner_id: u1.id, status: "reviewing", expiry_date: "2015-08-19", duration: 3, start_time: "11:00", end_time: "19:00", avatar_path: "https://s3-ap-southeast-1.amazonaws.com/media.clockworksmu.herokuapp.com/app/public/assets/logos/assembly_img.png", latitude: 1.3374734, longitude: 103.6969333)
			c9 = Post.create!(header: "Ice Cutter", company: "IceIceBaby", salary: 10.0, description: "Scooping Ice cream till you're ice baby SEED-DEMO", location: "50 Jurong Gateway Road, 608549", posting_date: "2015-09-14", job_date: today+41, end_date: today+43, owner_id: u4.id, status: "listed", expiry_date: today+40, duration: 3, start_time: "11:00", end_time: "21:00", avatar_path: u4.avatar_path, latitude: 1.3343388, longitude: 103.740543)
			c10 = Post.create!(header: "Ice Cream Sculpter", company: "iScreamStory", salary: 8.5, description: "Sculpting ice cream! need young people SEED-DEMO", location: "1 Pasir Ris Cl, 519599", posting_date: "2015-09-14", job_date: today+19, end_date: today+21, owner_id: u5.id, status: "listed", expiry_date: today+30, duration: 3, start_time: "11:00", end_time: "21:00", avatar_path: u5.avatar_path, latitude: 1.3793365, longitude: 103.9550175)
			c11 = Post.create!(header: "Meat Cutter", company: "The Meat Lover's Club", salary: 10.0, description: "Cut meat, eat meat, love meat SEED-DEMO", location: "4 Tampines Central 5, 529510", posting_date: "2015-08-14", job_date: "2015-09-10", end_date: "2015-09-11", owner_id: u6.id, status: "completed", expiry_date: "2015-09-09", duration: 2, start_time: "11:00", end_time: "21:00", avatar_path: u6.avatar_path, latitude: 1.3526609, longitude: 103.945245)
			c12 = Post.create!(header: "Cooking Master", company: "Flip Flop Cookery", salary: 12.0, description: "Cooking food, being a master at it SEED-DEMO", location: "1 Expo Dr, 486150", posting_date: "2015-08-01", job_date: today+28, end_date: today+29, owner_id: u1.id, status: "applied", expiry_date: today+35, duration: 2, start_time: "11:00", end_time: "19:00", avatar_path: u1.avatar_path, latitude: 1.332875, longitude: 103.9590039)
			c13 = Post.create!(header: "Jack of All Trades", company: "Bricks N Cubes", salary: 9.5, description: "jacking people professionally SEED-DEMO", location: "10 Changi Business Park Central 2, 486030", posting_date: "2015-08-01", job_date: today+29, end_date: today+30, owner_id: u1.id, status: "applied", expiry_date: today+35, duration: 2, start_time: "11:00", end_time: "19:00", avatar_path: "https://s3-ap-southeast-1.amazonaws.com/media.clockworksmu.herokuapp.com/app/public/assets/logos/bricks+and+cubes.jpg", latitude: 1.33571, longitude: 103.966545)

			m1 = Post.create!(header: "Service Crew", company: "Dazzling Cafe", salary: 10, description: "If you are looking to join an energetic, fun and vibrant team that offers on the job training and support, then join Mission Juice today! If you value commitment, professionalism and have a keen interest in learning and enhancing your skill set, join the Mission Juice team today! If you want to be among a group of people who want to progress together by working hard and want a place where you can excel and to find your full potential, then join the Mission Juice team today! If you have passion to serve and to make the world a happier place one juice at a time, then we want you! We want to hear from you! Full Time and Part time available! SEED-DEMO", location: "8 Sentosa Gateway, Resorts World Sentosa, Singapore 098269", posting_date: "2015-08-01", job_date: today+10, end_date: today+11, owner_id: u1.id, status: "listed", expiry_date: today+9, duration: 2, start_time: "11:00", end_time: "19:00", avatar_path: "https://s3-ap-southeast-1.amazonaws.com/media.clockworksmu.herokuapp.com/app/public/assets/logos/Dazzling+Cafe.jpg", latitude: 1.256752, longitude: 103.820331)
			m2 = Post.create!(header: "Ice Cream Scooper", company: "Daily Scoop", salary: 9.5, description: "If you are looking to join an energetic, fun and vibrant team that offers on the job training and support, then join Mission Juice today! If you value commitment, professionalism and have a keen interest in learning and enhancing your skill set, join the Mission Juice team today! If you want to be among a group of people who want to progress together by working hard and want a place where you can excel and to find your full potential, then join the Mission Juice team today! If you have passion to serve and to make the world a happier place one juice at a time, then we want you! We want to hear from you! Full Time and Part time available! SEED-DEMO", location: "27 Bukit Manis Road, 099892", posting_date: "2015-08-01", job_date: today+20, end_date: today+25, owner_id: u1.id, status: "listed", expiry_date: today+19, duration: 6, start_time: "11:00", end_time: "19:00", avatar_path: "https://s3-ap-southeast-1.amazonaws.com/media.clockworksmu.herokuapp.com/app/public/assets/logos/The+Daily+Scoop.png", latitude: 1.2438514, longitude: 103.8293374)
			m3 = Post.create!(header: "The Barista", company: "The Orange Thimble", salary: 10, description: "If you are looking to join an energetic, fun and vibrant team that offers on the job training and support, then join Mission Juice today! If you value commitment, professionalism and have a keen interest in learning and enhancing your skill set, join the Mission Juice team today! If you want to be among a group of people who want to progress together by working hard and want a place where you can excel and to find your full potential, then join the Mission Juice team today! If you have passion to serve and to make the world a happier place one juice at a time, then we want you! We want to hear from you! Full Time and Part time available! SEED-DEMO", location: "10 Bukit Chermin Rd, 109918", posting_date: "2015-08-01", job_date: today+15, end_date: today+16, owner_id: u1.id, status: "listed", expiry_date: today+15, duration: 2, start_time: "11:00", end_time: "19:00", avatar_path: "https://s3-ap-southeast-1.amazonaws.com/media.clockworksmu.herokuapp.com/app/public/assets/logos/theorangethimblelogo.jpg", latitude: 1.267374, longitude: 103.808598)
			m4 = Post.create!(header: "Barista & Coffee Crew", company: "Dazzling Cafe", salary: 8.5, description: "If you are looking to join an energetic, fun and vibrant team that offers on the job training and support, then join Mission Juice today! If you value commitment, professionalism and have a keen interest in learning and enhancing your skill set, join the Mission Juice team today! If you want to be among a group of people who want to progress together by working hard and want a place where you can excel and to find your full potential, then join the Mission Juice team today! If you have passion to serve and to make the world a happier place one juice at a time, then we want you! We want to hear from you! Full Time and Part time available! SEED-DEMO", location: "1 Harbourfront Walk, Singapore 098585", posting_date: "2015-08-01", job_date: today+19, end_date: today+21, owner_id: u1.id, status: "listed", expiry_date: today+18, duration: 3, start_time: "11:00", end_time: "19:00", avatar_path: "https://s3-ap-southeast-1.amazonaws.com/media.clockworksmu.herokuapp.com/app/public/assets/logos/Dazzling+Cafe.jpg", latitude: 1.2642411, longitude: 103.8223265)

			Post.create!([
			  {header: "Frozen Yogurt Server", company: "Bricks N Cubes", salary: 10.0, description: "If you are looking to join an energetic, fun and vibrant team that offers on the job training and support, then join Mission Juice today! If you value commitment, professionalism and have a keen interest in learning and enhancing your skill set, join the Mission Juice team today! If you want to be among a group of people who want to progress together by working hard and want a place where you can excel and to find your full potential, then join the Mission Juice team today! If you have passion to serve and to make the world a happier place one juice at a time, then we want you! We want to hear from you! Full Time and Part time available! SEED-DEMO", location: "4 Seah Im Rd", posting_date: "2015-08-01", job_date: today+23, end_date: today+30, owner_id: u1.id, status: "listed", expiry_date: today+35, duration: 8, start_time: "11:00", end_time: "19:00", avatar_path: "https://s3-ap-southeast-1.amazonaws.com/media.clockworksmu.herokuapp.com/app/public/assets/logos/bricks+and+cubes.jpg", latitude: 1.266948, longitude: 103.819095},
			  {header: "Customer Service", company: "Bricks N Cubes", salary: 10.0, description: "We are seeking enthusiastic people to work with on full-time or part-time basis. Some experience in F&B service would be nice although not necessary. If you enjoy communicating with people and you are located in the East, come meet with us! SEED-DEMO", location: "42 Keppel Bay Dr, 098656", posting_date: "2015-08-11", job_date: "2015-11-02", end_date: "2015-11-05", owner_id: u1.id, status: "listed", expiry_date: "2015-01-01", duration: 8, start_time: "11:00", end_time: "19:00", avatar_path: "https://s3-ap-southeast-1.amazonaws.com/media.clockworksmu.herokuapp.com/app/public/assets/logos/bricks+and+cubes.jpg", latitude: 1.266828, longitude: 103.814525}
			])

			Matching.create!([
			  {applicant_id: u3.id, post_id: c1.id, status: "completed", user_rating: -1, comments: "Came late left early"},
			  {applicant_id: u3.id, post_id: c2.id, status: "completed", user_rating: -1, comments: "Not very good worker"},
			  {applicant_id: u3.id, post_id: c3.id, status: "completed", user_rating: 0, comments: nil},
			  {applicant_id: u3.id, post_id: c4.id, status: "completed", user_rating: 1, comments: "Hardworking, first to work everyday"},
			  {applicant_id: u3.id, post_id: c5.id, status: "completed", user_rating: 1, comments: "Friendly person"},
			  {applicant_id: u3.id, post_id: c6.id, status: "completed", user_rating: 1, comments: "Fun to work with"},
			  {applicant_id: hoi.id, post_id: c6.id, status: "completed", user_rating: 1, comments: "Funny guy"},
			  {applicant_id: hoi.id, post_id: c6.id, status: "completed", user_rating: 1, comments: "Very hardworking!"},
			  {applicant_id: hoi.id, post_id: c3.id, status: "completed", user_rating: 0, comments: "came and did his job"},
			  {applicant_id: u3.id, post_id: c7.id, status: "hired", user_rating: nil, comments: nil},
			  {applicant_id: u3.id, post_id: c8.id, status: "hired", user_rating: nil, comments: nil},
			  {applicant_id: u3.id, post_id: p1.id, status: "pending", user_rating: nil, comments: nil},
			  {applicant_id: u3.id, post_id: p2.id, status: "offered", user_rating: nil, comments: nil},
			  {applicant_id: u3.id, post_id: c12.id, status: "offered", user_rating: nil, comments: nil},
			  {applicant_id: u3.id, post_id: c13.id, status: "pending", user_rating: nil, comments: nil},
			  {applicant_id: u3.id, post_id: p3.id, status: "hired", user_rating: nil, comments: nil},
			  {applicant_id: u2.id, post_id: c11.id, status: "completed", user_rating: 1, comments: "Very prompt and responsive"}
			])

			Notification.create!([
			  {sender_id: c1.owner_id, receiver_id: u3.id, content: "#{c1.owner.username} has just rated you for your work at #{c1.header}!", avatar_path: c1.owner.avatar_path, post_id: c1.id},
			  {sender_id: c2.owner_id, receiver_id: u3.id, content: "#{c2.owner.username} has just rated you for your work at #{c2.header}!", avatar_path: c2.owner.avatar_path, post_id: c2.id},
			  {sender_id: c3.owner_id, receiver_id: u3.id, content: "#{c3.owner.username} has just rated you for your work at #{c3.header}!", avatar_path: c3.owner.avatar_path, post_id: c3.id},
			  {sender_id: c4.owner_id, receiver_id: u3.id, content: "#{c4.owner.username} has just rated you for your work at #{c4.header}!", avatar_path: c4.owner.avatar_path, post_id: c4.id},
			  {sender_id: c5.owner_id, receiver_id: u3.id, content: "#{c5.owner.username} has just rated you for your work at #{c5.header}!", avatar_path: c5.owner.avatar_path, post_id: c5.id},
			  {sender_id: c6.owner_id, receiver_id: u3.id, content: "#{c6.owner.username} has just rated you for your work at #{c6.header}!", avatar_path: c6.owner.avatar_path, post_id: c6.id},
			  {sender_id: u3.id, receiver_id: c7.owner_id, content: "#{u3.username} has accepted your a job offer!", avatar_path: u3.avatar_path, post_id: c7.id},
			  {sender_id: u3.id, receiver_id: p1.owner_id, content: "You have a new applicant for your job (#{p1.header})", avatar_path: u3.avatar_path, post_id: p1.id},
			  {sender_id: p2.owner_id, receiver_id: u3.id, content: "#{p2.owner.username} has offered you a job for #{p2.header}", avatar_path: p2.owner.avatar_path, post_id: p2.id},
			  {sender_id: c12.owner_id, receiver_id: u3.id, content: "#{c12.owner.username} has offered you a job for #{c12.header}", avatar_path: c12.owner.avatar_path, post_id: c12.id},
			  {sender_id: u3.id, receiver_id: c13.owner_id, content: "You have a new applicant for your job (#{c13.header})", avatar_path: u3.avatar_path, post_id: c13.id},
			  {sender_id: u3.id, receiver_id: p3.owner_id, content: "#{u3.username} has accepted your a job offer!", avatar_path: u3.avatar_path, post_id: p3.id},
			  {sender_id: c11.owner_id, receiver_id: u2.id, content: "You have received a new rating for your recently completed job!", avatar_path: c11.owner.avatar_path, post_id: c11.id}
			])

			Score.create!([
				{owner_id: u2.id},
				{owner_id: u3.id},
				{owner_id: hoi.id}
			])

			Badge.create!([
				{name: "Newbie", criteria: "Complete your first job", badge_id: "newbie"},
				{name: "Adventurer", criteria: "Explore 5 different restaurants / roles", badge_id: "adventurer"},
				{name: "Jack Of All Trades", criteria: "Explore 10 different restaurants / roles", badge_id: "jackofalltrades"},
				{name: "Master Chef", criteria: "Work as a chef for 10 times", badge_id: "masterchef"},
				{name: "Master Ice Cream Scooper", criteria: "Work in an Ice Cream parlour for 10 times", badge_id: "mastericecreamscooper"},
				{name: "Master Waiter", criteria: "Work as a waiter for 10 times", badge_id: "masterwaiter"},
				{name: "Devoted", criteria: "Worked for the same employer 5 times", badge_id: "devoted"},
				{name: "Superman", criteria: "Worked for 4 days in a role", badge_id: "superman"},
				{name: "Bookworm", criteria: "Complete 3 quizzes", badge_id: "bookworm"},
				{name: "Scholar", criteria: "Score at least 70% for 5 quizzes", badge_id: "scholar"},
				{name: "Super User", criteria: "Applied jobs for 5 days in a row", badge_id: "superuser"},
				{name: "Lovable", criteria: "Received 5 positive feedback", badge_id: "lovable"},
				{name: "Social Butterfly", criteria: "Refer 5 friends to join Clockwork!", badge_id: "socialbutterfly"},
			])

			# genres: [service, kitchen, bartender, barista, order_taking, cashier, clean_up, selling]
			Question.create!([
				{question: "What is the purpose of sanitising?", choice_a: "To get rid of invisible germs", choice_b: "To remove visible stains", choice_c: "To impress your boss", choice_d: "Because there isn't any other way of cleaning", answer: "a", genre: "clean_up"},
				{question: "Which one should come first? Sanitising or Cleaning", choice_a: "Cleaning", choice_b: "Sanitising", choice_c: "It doesn't matter", choice_d: "This is a trick question, neither are useful", answer: "b", genre: "clean_up"},
				{question: "What is the most common type of water to wash with?", choice_a: "Boiling water", choice_b: "Cold water", choice_c: "Room temperature water", choice_d: "All are the same.", answer: "c", genre: "clean_up"},
				{question: "What should be the order of work?", choice_a: "Pre-clean > Wash and Rinse > Sanitise > Dry", choice_b: "Pre-clean > Sanitise > Wash and Rinse > Dry", choice_c: "Wash and Rinse > Sanitise > Pre-clean > Dry", choice_d: "None of the above", answer: "a", genre: "clean_up"},
				{question: "Why should items be dry completely before storing", choice_a: "It makes it cleaner", choice_b: "It does not attract pests", choice_c: "It prevents micro-organism growth", choice_d: "It doesn't matter, it will drip dry during storage", answer: "c", genre: "clean_up"},
			])

			QuestionHistory.create!([
				{owner_id: u2.id},
				{owner_id: u3.id},
				{owner_id: hoi.id}
			])
	    end  
	end

##########################################################################################################################
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
		    		start_date = job.job_date
		    		end_date = job.end_date

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
##########################################################################################################################
		# API FOR DEVELOPERS
		desc "get device token - for dev only"
	    params do
			requires :email, 		type: String
		end
	    post :get_device_token, 
	    :http_codes => [
	    	[200, "Get successful"],
	    	[400, "Device not found"] 
    	] do
	      	user = User.where(email: params[:email]).first
	      	if user
	      		device = Device.where(owner_id: user.id).first.device_id
	      		
	      		status 200
	      		device.to_json
	      	else 
	  			error!("No device registered under this user", 400)
	  		end
	    end  
##########################################################################################################################
	end
end