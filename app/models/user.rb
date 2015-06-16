class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  	devise 	:database_authenticatable, :registerable,
    	 	:recoverable, :rememberable, :trackable, :validatable

	def self.authenticate(user_id)
    	token = ApiKey.where(user_id: user_id).first
	    if token && !token.expired?
	      @current_user = User.find(token.user_id)
	      return token
	    else
	      false
	    end
  	end

  	def self.authenticate_token(token)
    	token = ApiKey.where(access_token: token).first
	    if token && !token.expired?
	      @current_user = User.find(token.user_id)
	      return true
	    else
	      return false
	    end 
  	end
end
