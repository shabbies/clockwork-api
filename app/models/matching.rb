class Matching < ActiveRecord::Base
	belongs_to :applicant, :class_name => "User", :foreign_key => "applicant_id"
	belongs_to :post

	default_scope { where.not(status: "withdrawn") }
end
