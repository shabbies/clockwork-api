class Post < ActiveRecord::Base
	include PgSearch
	nilify_blanks
 	# after_save :issue_badges
 	after_save :send_notifications, if: :status_changed?
 	after_save :create_chat_room, if: :status_changed?

	belongs_to 	:owner, 			:class_name => "User", 	:foreign_key => "owner_id"
	has_many		:matchings, 	:dependent => :destroy, :foreign_key => "post_id"
	has_many		:applicants,	:class_name => "User", 	through: :matchings
	has_one  		:chatroom,    :dependent => :destroy, :foreign_key => "post_id", autosave: true

	geocoded_by :location   # can also be an IP address
	after_validation :geocode, unless: :is_seed

	has_attached_file :post_image, 			
    :path => ":rails_root/public/post_images/:filename", 
    :bucket  => ENV['media.clockworksmu.herokuapp.com'],
    :source_file_options => { all:     '-auto-orient' }
 
 	validates_attachment_content_type 	:post_image, :content_type => ["image/jpg", "image/jpeg", "image/png", "image/gif"]

	pg_search_scope :search_by_header_and_desc, :against => [:header, :description, :location, :company, :salary], 
		:using => {
        :tsearch => {:prefix => true, :any_word => true}
  	}

	private 
	def is_seed
		description.include? "SEED-DEMO"
	end

	def send_notifications
		case status
		when "reviewing"
			Notification.create!(:sender_id => owner_id, :receiver_id => owner_id, :content => "Your post #{header} has been completed! Please review your employees", :avatar_path => avatar_path, :post_id => id)
		when "expired"
			Notification.create!(:sender_id => owner_id, :receiver_id => owner_id, :content => "Your post #{header} has expired!", :avatar_path => avatar_path, :post_id => id)
			remaining_applicants = Matching.where(:post_id => id).where.not(:status => ["hired", "completed", "reviewing"])
			remaining_applicants.each do |applicant|
				Notification.create!(:sender_id => owner_id, :receiver_id => applicant.applicant_id, :content => "Your application for #{header} has expired!", :avatar_path => avatar_path, :post_id => id)
			end
		end
	end

	def create_chat_room
		case status
		when "applied"
			chatroom = Chatroom.create!(post_id: id)
			ChatroomParticipant.create!(chatroom_id: chatroom.id, user_id: owner_id, post_id: id)
		end
	end

	def self.update_listings
		posts = Post.where.not(status: ["completed", "expired"]).all
		posts.each do |post|
			expiry_date = post.expiry_date
			status = post.status
			case status
				when "listed"
					matchings = Matching.where(post_id: post.id, status: "hired")
					if matchings.count == 0 && (expiry_date < Time.now.to_date || (expiry_date == Time.now.to_date && post.start_time.to_time < Time.now))
						post.update_attributes(status: "expired")
					end
				when "applied"
					if expiry_date < Time.now.to_date || (expiry_date == Time.now.to_date && post.start_time.to_time < Time.now)
						post.update_attributes(status: "ongoing")
					end
				when "ongoing"
					end_date = post.end_date
					if end_date < Time.now.to_date
						post.update_attributes(status: "reviewing")
					end
				when "reviewing"
					matchings = Matching.where(post_id: post.id, user_rating: nil)
					if matchings.count == 0
						post.update_attributes(status: "completed")
					end
			end
		end
	end

	# def issue_badges
	# 	issue_newbie_badge
	# 	issue_devoted_badge
	# 	issue_superman_badge
	# end

	# def issue_newbie_badge
	# 	if status == "reviewing"
	# 		matchings = Matching.where(post_id: self.id, status: "hired")
 #  		matchings.each do |matching|
 #  			applicant = matching.applicant
 #  			app_obtained_badges = applicant.obtained_badges
 #  			unless app_obtained_badges.include? "newbie"
 #  				app_obtained_badges << "newbie" 
 #  				applicant.obtained_badges = app_obtained_badges
 #  				applicant.save!
 #  			end
 #  		end
 #  	end
	# end

	# def issue_devoted_badge
	# 	if status == "reviewing"
	# 		matchings = Matching.where(post_id: id, status: "hired")
 #  		matchings.each do |matching|
 #  			applicant = matching.applicant
 #  			app_obtained_badges = applicant.obtained_badges
 #  			unless app_obtained_badges.include? "devoted"
 #  				running_total = 0
 #  				app_applications = Matching.where(applicant_id: applicant.id, status: "completed")
 #  				app_applications.each do |application|
 #  					past_owner = application.post.owner_id
 #  					if past_owner == owner_id
 #  						running_total += 1
	# 					end
 #  				end
 #  				if running_total > 4
 #  					app_obtained_badges << "devoted"
 #  					applicant.obtained_badges = app_obtained_badges
 #  					applicant.save!
 #  				end
 #  			end
 #  		end
 #  	end
	# end

	# def issue_superman_badge
	# 	if status == "reviewing" && (end_date - job_date + 1) > 4
	# 		matchings = Matching.where(post_id: self.id, status: "hired")
 #  		matchings.each do |matching|
 #  			applicant = matching.applicant
 #  			app_obtained_badges = applicant.obtained_badges
 #  			unless app_obtained_badges.include? "superman"
 #  				app_obtained_badges << "superman" 
 #  				applicant.obtained_badges = app_obtained_badges
 #  				applicant.save!
 #  			end
 #  		end
 #  	end
	# end
end