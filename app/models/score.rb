class Score < ActiveRecord::Base
	belongs_to :owner, :class_name => "User", :foreign_key => "owner_id"

 	after_save :issue_badges, if: :quiz_score_changed?

 	private
 	def issue_badges
 		issue_bookworm_badge
 		issue_scholar_badge
 	end

 	def issue_bookworm_badge
 		owner_badges = owner.obtained_badges
		unless owner_badges.include? "bookworm"
			if quiz_count > 2
				owner_badges << "bookworm"
				owner.obtained_badges = owner_badges
				owner.save
			end
		end
 	end

 	def issue_scholar_badge
 		owner_badges = owner.obtained_badges
		unless owner_badges.include? "scholar"
			if quiz_count > 4
				average = quiz_score / quiz_count
				if average > 35
					owner_badges << "scholar"
					owner.obtained_badges = owner_badges
					owner.save
				end
			end
		end
 	end
end
