class Device < ActiveRecord::Base
	nilify_blanks

	belongs_to 	:owner, 		:class_name => "User", 	:foreign_key => "owner_id"
end
