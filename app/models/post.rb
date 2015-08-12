class Post < ActiveRecord::Base
	nilify_blanks

	belongs_to 				:owner, 		:class_name => "User", 	:foreign_key => "owner_id"
	has_and_belongs_to_many	:applicants,	:class_name => "User", 	:join_table => :posts_users
	has_and_belongs_to_many :hired,			:class_name => "User", 	:join_table => :posts_users_hired
end