u1 = User.find(45)
u1.good_ratings = 3
u1.neutral_ratings = 1
u1.bad_ratings = 2
u1.save

joan_shue = User.find(207)
joan_shue.good_ratings = 1
joan_shue.neutral_ratings = 0
joan_shue.bad_ratings = 0
joan_shue.save

ice_ice_baby = User.find(208)
i_scream_story = User.find(210)
the_meat_lovers_club = User.find(211)

p1 = Post.create!(header: "Service Crew", company: "ShuKuu Izakaya", salary: 10.0, description: "Housewives, Students are welcome!", location: "Chinatown", posting_date: "2015-08-11", job_date: "2016-01-03", end_date: "2016-01-10", owner_id: 45, status: "applied", expiry_date: "2016-01-02", duration: 7, start_time: "11:00", end_time: "18:00", avatar_path: u1.avatar_path)
c1 = Post.create!(header: "Weekend Dishwasher", company: "DIS Manpower Pte Ltd", salary: 9.5, description: "Job Scope - clear some stuff, load dishes into machine, unload dry store", location: "Orchard", posting_date: "2015-07-21", job_date: "2015-08-22", end_date: "2015-08-21", owner_id: 45, status: "completed", expiry_date: "2015-08-21", duration: 2, start_time: "11:00", end_time: "13:00", avatar_path: u1.avatar_path)
e1 = Post.create!(header: "Cafe Service Crew", company: "TCC Manpower Pte Ltd", salary: 9.2, description: "Job Scope - Serving food and drinks, Clearing or just restaurant food runner duties, Basic Housekeeping duties", location: "Suntec City", posting_date: "2015-08-21", job_date: "2015-08-24", end_date: "2015-08-27", owner_id: 45, status: "expired", expiry_date: "2015-08-23", duration: 3, start_time: "11:00", end_time: "14:00", avatar_path: u1.avatar_path)
p2 = Post.create!(header: "Poolside Bar Service", company: "Henry Almighty", salary: 8.5, description: "Can commit 5 or more days per week and for 3 MONTHS", location: "Suntec City", posting_date: "2015-08-21", job_date: "2015-09-25", end_date: "2015-09-27", owner_id: 45, status: "listed", expiry_date: "2015-09-24", duration: 2, start_time: "11:00", end_time: "13:00", avatar_path: u1.avatar_path)
c2 = Post.create!(header: "Japanese Spaghetti House", company: "Japanese Spaghetti House", salary: 9.0, description: "Japanese Spaghetti House Part-time Service crew Job Scope: Greeting customers, Serving food and drinks Top up drinks Clearing empty dishes", location: "Tanjong Pagar", posting_date: "2015-08-01", job_date: "2015-09-27", end_date: "2015-09-30", owner_id: 45, status: "completed", expiry_date: "2015-09-26", duration: 3, start_time: "11:00", end_time: "14:00", avatar_path: u1.avatar_path)
c3 = Post.create!(header: "Server", company: "tcchr", salary: 10.5, description: "SERVING OF FOOD AND DRINKS", location: "Sentosa", posting_date: "2015-08-01", job_date: "2015-08-27", end_date: "2015-08-28", owner_id: 45, status: "completed", expiry_date: "2015-08-26", duration: 2, start_time: "11:00", end_time: "13:00", avatar_path: u1.avatar_path)
c4 = Post.create!(header: "Service Crew", company: "Cool Orchard Clubs", salary: 8.1, description: "Operating 7 F&B Restaurants, Bistros & Bars", location: "Orchard", posting_date: "2015-08-01", job_date: "2015-08-28", end_date: "2015-08-30", owner_id: 45, status: "completed", expiry_date: "2015-08-27", duration: 1, start_time: "11:00", end_time: "12:00", avatar_path: u1.avatar_path)
c5 = Post.create!(header: "Service Crew", company: "Western Restaurant", salary: 8.0, description: "Taking Orders, Serving Food & Drinks & Clearing Tables", location: "Toa Payoh", posting_date: "2015-08-01", job_date: "2015-09-29", end_date: "2015-10-02", owner_id: 45, status: "completed", expiry_date: "2015-08-28", duration: 3, start_time: "11:00", end_time: "14:00", avatar_path: u1.avatar_path)
c6 = Post.create!(header: "Waiter", company: "Japanese Restaurant", salary: 9.0, description: "Taking Orders, Serving Food & Drinks & Clearing Tables", location: "Buona Vista", posting_date: "2015-08-01", job_date: "2015-08-30", end_date: "2015-09-05", owner_id: 45, status: "completed", expiry_date: "2015-08-29", duration: 8, start_time: "11:00", end_time: "19:00", avatar_path: u1.avatar_path)
Post.create!(header: "Hotel Cafe", company: "Studio M Hotel", salary: 12.0, description: "Responsibilities: - Greet and welcome guests, assist in taking F&B orders and ensure prompt serving", location: "Tanglin", posting_date: "2015-08-21", job_date: "2015-09-21", end_date: "2015-09-25", owner_id: 45, status: "expired", expiry_date: "2015-08-20", duration: 8, start_time: "11:00", end_time: "19:00", avatar_path: u1.avatar_path)
p3 = Post.create!(header: "Restaurant Crew", company: "DIS Manpower Pte Ltd", salary: 9.0, description: "Job Scope - Serving food and drinks, Clearing or just restaurant food runner duties, Basic Housekeeping duties", location: "Boat Quay", posting_date: "2015-08-21", job_date: "2015-09-23", end_date: "2015-09-27", owner_id: 45, status: "applied", expiry_date: "2015-09-22", duration: 8, start_time: "11:00", end_time: "19:00", avatar_path: u1.avatar_path)
c7 = Post.create!(header: "Cooking Crew", company: "Manpower Pte Ltd", salary: 9.0, description: "Cooking food", location: "Raffles Place", posting_date: "2015-08-01", job_date: "2015-10-26", end_date: "2015-10-27", owner_id: 45, status: "reviewing", expiry_date: "2015-09-25", duration: 8, start_time: "11:00", end_time: "19:00", avatar_path: u1.avatar_path)
c8 = Post.create!(header: "Banquet Server", company: "TCCHR", salary: 8.0, description: "WE ARE HIRING !!! PT & FT Server @5* Hotel", location: "City Hall", posting_date: "2015-08-21", job_date: "2015-09-20", end_date: "2015-09-27", owner_id: 45, status: "reviewing", expiry_date: "2015-08-19", duration: 8, start_time: "11:00", end_time: "19:00", avatar_path: u1.avatar_path)
c9 = Post.create!(header: "Ice Cream Scooper", company: "IceIceBaby", salary: 10.0, description: "Scooping Ice cream till you're ice baby", location: "Ang Mo Kio Ave 10", posting_date: "2015-09-14", job_date: "2015-09-18", end_date: "2015-09-20", owner_id: 208, status: "listed", expiry_date: "2015-09-17", duration: 3, start_time: "11:00", end_time: "21:00", avatar_path: ice_ice_baby.avatar_path)
c10 = Post.create!(header: "Ice Cream Sculpter", company: "iScreamStory", salary: 8.5, description: "Sculpting ice cream! need young people", location: "East Coast Parkway", posting_date: "2015-09-14", job_date: "2015-09-19", end_date: "2015-09-21", owner_id: 210, status: "listed", expiry_date: "2015-09-18", duration: 3, start_time: "11:00", end_time: "21:00", avatar_path: i_scream_story.avatar_path)
c11 = Post.create!(header: "Meat Cutter", company: "The Meat Lover's Club", salary: 10.0, description: "Cut meat, eat meat, love meat", location: "Jurong Mall", posting_date: "2015-08-14", job_date: "2015-09-10", end_date: "2015-09-11", owner_id: 211, status: "completed", expiry_date: "2015-09-09", duration: 2, start_time: "11:00", end_time: "21:00", avatar_path: the_meat_lovers_club.avatar_path)
c12 = Post.create!(header: "Cooking Master", company: "Flip Flop Cookery", salary: 12.0, description: "Cooking food, being a master at it", location: "Raffles Place", posting_date: "2015-08-01", job_date: "2015-09-25", end_date: "2015-09-26", owner_id: 45, status: "applied", expiry_date: "2015-09-24", duration: 2, start_time: "11:00", end_time: "19:00", avatar_path: u1.avatar_path)
c13 = Post.create!(header: "Jack of All Trades", company: "Jack's Place", salary: 9.5, description: "jacking people professionally", location: "Raffles Place", posting_date: "2015-08-01", job_date: "2015-09-26", end_date: "2015-09-27", owner_id: 45, status: "applied", expiry_date: "2015-09-25", duration: 2, start_time: "11:00", end_time: "19:00", avatar_path: u1.avatar_path)

Post.create!([
  {header: "Frozen Yogurt Server", company: "Mission Juice", salary: 10.0, description: "If you are looking to join an energetic, fun and vibrant team that offers on the job training and support, then join Mission Juice today! If you value commitment, professionalism and have a keen interest in learning and enhancing your skill set, join the Mission Juice team today! If you want to be among a group of people who want to progress together by working hard and want a place where you can excel and to find your full potential, then join the Mission Juice team today! If you have passion to serve and to make the world a happier place one juice at a time, then we want you! We want to hear from you! Full Time and Part time available!", location: "Tanjong Pagar", posting_date: "2015-08-01", job_date: "2015-09-26", end_date: "2015-09-27", owner_id: 45, status: "listed", expiry_date: "2015-09-25", duration: 8, start_time: "11:00", end_time: "19:00", avatar_path: u1.avatar_path},
  {header: "Customer Service", company: "Next Door Cafe & Taverna", salary: 10.0, description: "We are seeking enthusiastic people to work with on full-time or part-time basis. Some experience in F&B service would be nice although not necessary. If you enjoy communicating with people and you are located in the East, come meet with us!", location: "Bedok", posting_date: "2015-08-11", job_date: "2015-11-02", end_date: "2015-11-05", owner_id: 45, status: "listed", expiry_date: "2015-01-01", duration: 8, start_time: "11:00", end_time: "19:00", avatar_path: u1.avatar_path}
])
Matching.create!([
  {applicant_id: 75, post_id: c1.id, status: "completed", user_rating: -1, comments: "Came late left early"},
  {applicant_id: 75, post_id: c2.id, status: "completed", user_rating: -1, comments: "Not very good worker"},
  {applicant_id: 75, post_id: c3.id, status: "completed", user_rating: 0, comments: nil},
  {applicant_id: 75, post_id: c4.id, status: "completed", user_rating: 1, comments: "Hardworking, first to work everyday"},
  {applicant_id: 75, post_id: c5.id, status: "completed", user_rating: 1, comments: "Friendly person"},
  {applicant_id: 75, post_id: c6.id, status: "completed", user_rating: 1, comments: "Fun to work with"},
  {applicant_id: 75, post_id: c7.id, status: "hired", user_rating: nil, comments: nil},
  {applicant_id: 75, post_id: c8.id, status: "reviewing", user_rating: nil, comments: nil},
  {applicant_id: 75, post_id: p1.id, status: "pending", user_rating: nil, comments: nil},
  {applicant_id: 75, post_id: p2.id, status: "offered", user_rating: nil, comments: nil},
  {applicant_id: 75, post_id: c12.id, status: "offered", user_rating: nil, comments: nil},
  {applicant_id: 75, post_id: c13.id, status: "pending", user_rating: nil, comments: nil},
  {applicant_id: 75, post_id: p3.id, status: "hired", user_rating: nil, comments: nil},
  {applicant_id: 207, post_id: c11.id, status: "completed", user_rating: 1, comments: "Very prompt and responsive"}
])