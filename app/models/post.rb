class Post < ActiveRecord::Base
	nilify_blanks
	
	belongs_to 	:owner, 		:class_name => "User", 	:foreign_key => "owner_id"
	has_many 	:applicants, 	:class_name => "User",	:foreign_key => "applicant_id"
	has_many	:employed,		:class_name => "User"
end