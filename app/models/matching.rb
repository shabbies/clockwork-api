class Matching < ActiveRecord::Base
	belongs_to :applicant, :class_name => "User"
	belongs_to :post
end
