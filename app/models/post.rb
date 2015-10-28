class Post < ActiveRecord::Base
	include PgSearch
	nilify_blanks

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
end