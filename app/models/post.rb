class Post < ActiveRecord::Base
	include PgSearch
	nilify_blanks

	belongs_to 	:owner, 		:class_name => "User", 	:foreign_key => "owner_id"
	has_many	:matchings, 	:dependent => :destroy, :foreign_key => "post_id"
	has_many	:applicants,	:class_name => "User", 	through: :matchings

	pg_search_scope :search_by_header_and_desc, :against => [:header, :description], 
		:using => {
            :tsearch => {:any_word => true}
      	}
end