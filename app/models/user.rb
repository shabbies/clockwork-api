class User < ActiveRecord::Base
	nilify_blanks
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  	devise 	:database_authenticatable, :registerable,
    	 	:recoverable, :rememberable, :trackable, :validatable
  	
  	before_save :ensure_authentication_token
    before_save :ensure_referral_id
    validates_uniqueness_of :nric

  	has_many :published_jobs, 			:class_name => "Post", 	:foreign_key => "owner_id"
  	has_many :sent_notifications, 		:class_name => "Notification", 	:foreign_key => "sender_id", 	:dependent => :destroy
  	has_many :received_notifications, 	:class_name => "Notification", 	:foreign_key => "receiver_id", 	:dependent => :destroy
  	has_many :matchings,				:dependent => :destroy, :foreign_key => "applicant_id"
  	has_many :jobs,						:class_name => "Post", 	through: :matchings,	:source => "applicant"
  	has_many :devices, 					:class_name => "Device", 	:foreign_key => "owner_id"
  	has_attached_file :avatar, 			
  		:path => ":rails_root/public/avatars/:filename", 
  		:bucket  => ENV['media.clockworksmu.herokuapp.com'],
  		:source_file_options => { all:     '-auto-orient' },
  		:styles => {
  			:thumb => "100x100"
  		}
  	validates_attachment_content_type 	:avatar, :content_type => ["image/jpg", "image/jpeg", "image/png", "image/gif"]

    geocoded_by :address   # can also be an IP address
    after_validation :geocode

	def ensure_authentication_token
	  	if authentication_token.blank?
	    	  self.authentication_token = generate_authentication_token
	  	end
	end

  def ensure_referral_id
      if referral_id.blank?
          self.referral_id = generate_referral_id
      end
  end

	private

    def generate_authentication_token
    	loop do
	      	token = Devise.friendly_token
	      	break token unless User.find_by(authentication_token: token)
    	end
  	end

  	def self.check_contact_number string
  		true if Float(string) rescue false
  	end

    def self.generate_referral_id
      loop do
          token = Devise.friendly_token(8)
          break token unless User.find_by(referral_id: token)
      end
    end
end