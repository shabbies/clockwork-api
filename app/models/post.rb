class Post < ActiveRecord::Base
	include PgSearch
	nilify_blanks
 	after_save :issue_badges


	belongs_to 	:owner, 		:class_name => "User", 	:foreign_key => "owner_id"
	has_many	:matchings, 	:dependent => :destroy, :foreign_key => "post_id"
	has_many	:applicants,	:class_name => "User", 	through: :matchings

	geocoded_by :location   # can also be an IP address
	after_validation :geocode, unless: :is_seed

	pg_search_scope :search_by_header_and_desc, :against => [:header, :description, :location, :company, :salary], 
		:using => {
            :tsearch => {:prefix => true, :any_word => true}
      	}

  	private 
  	def is_seed
  		description.include? "SEED-DEMO"
  	end

  	def issue_badges
  		issue_newbie_badge
  		issue_devoted_badge
  		issue_superman_badge
  	end

  	def issue_newbie_badge
  		if status == "reviewing"
  			matchings = Matching.where(post_id: self.id, status: "hired")
	  		matchings.each do |matching|
	  			applicant = matching.applicant
	  			app_obtained_badges = applicant.obtained_badges
	  			unless app_obtained_badges.include? "newbie"
	  				app_obtained_badges << "newbie" 
	  				applicant.obtained_badges = app_obtained_badges
	  				applicant.save!
	  			end
	  		end
	  	end
  	end

  	def issue_devoted_badge
  		if status == "reviewing"
  			matchings = Matching.where(post_id: id, status: "hired")
	  		matchings.each do |matching|
	  			applicant = matching.applicant
	  			app_obtained_badges = applicant.obtained_badges
	  			unless app_obtained_badges.include? "devoted"
	  				running_total = 0
	  				app_applications = Matching.where(applicant_id: applicant.id, status: "completed")
	  				app_applications.each do |application|
	  					past_owner = application.post.owner_id
	  					if past_owner == owner_id
	  						running_total += 1
  						end
	  				end
	  				if running_total > 4
	  					app_obtained_badges << "devoted"
	  					applicant.obtained_badges = app_obtained_badges
	  					applicant.save!
	  				end
	  			end
	  		end
	  	end
  	end

  	def issue_superman_badge
  		if status == "reviewing" && (end_date - job_date + 1) > 4
  			matchings = Matching.where(post_id: self.id, status: "hired")
	  		matchings.each do |matching|
	  			applicant = matching.applicant
	  			app_obtained_badges = applicant.obtained_badges
	  			unless app_obtained_badges.include? "superman"
	  				app_obtained_badges << "superman" 
	  				applicant.obtained_badges = app_obtained_badges
	  				applicant.save!
	  			end
	  		end
	  	end
  	end
end