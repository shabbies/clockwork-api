class Post < ActiveRecord::Base
	nilify_blanks

	belongs_to 	:owner, 		:class_name => "User", 	:foreign_key => "owner_id"
	has_many	:matchings, 	:dependent => :destroy, :foreign_key => "post_id"
	has_many	:applicants,	:class_name => "User", 	through: :matchings

	searchable  do
		text :header
		text :description
	end
end