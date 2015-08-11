class User < ActiveRecord::Base
	nilify_blanks
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  	devise 	:database_authenticatable, :registerable,
    	 	:recoverable, :rememberable, :trackable, :validatable
  	
  	before_save :ensure_authentication_token

  	has_many 	:published_jobs, 	:class_name => "Post", 	:foreign_key => "owner_id"
  	has_many 	:past_jobs,			:class_name => "Post", 	:foreign_key => "owner_id" 
  	belongs_to	:applied_job,		:class_name => "Post", 	:foreign_key => "applicant_id"

	def ensure_authentication_token
	  	if authentication_token.blank?
	    	self.authentication_token = generate_authentication_token
	  	end
	end

	private

    def generate_authentication_token
    	loop do
	      	token = Devise.friendly_token
	      	break token unless User.find_by(authentication_token: token)
    	end
  	end

	# def self.authenticate(user_id)
 #    	token = ApiKey.where(user_id: user_id).first
	#     if token && !token.expired?
	#       @current_user = User.find(token.user_id)
	#       return token
	#     else
	#       false
	#     end
 #  	end

 #  	def self.authenticate_token(token)
 #    	token = ApiKey.where(access_token: token).first
	#     if token && !token.expired?
	#       @current_user = User.find(token.user_id)
	#       return true
	#     else
	#       return false
	#     end 
 #  	end
end