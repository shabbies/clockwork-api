class User < ActiveRecord::Base
	nilify_blanks
      # Include default devise modules. Others available are:
      # :confirmable, :lockable, :timeoutable and :omniauthable
    devise 	:database_authenticatable, :registerable, :recoverable, :rememberable, :trackable, :validatable, :confirmable

    before_save :ensure_authentication_token
    before_save :ensure_referral_id
    after_save :issue_badges, if: (:good_rating_changed? || :referred_users_changed?)

    has_many :published_jobs, 			:class_name => "Post", 	:foreign_key => "owner_id"
    has_many :sent_notifications, 		:class_name => "Notification", 	:foreign_key => "sender_id", 	:dependent => :destroy
    has_many :received_notifications, 	:class_name => "Notification", 	:foreign_key => "receiver_id", 	:dependent => :destroy
    has_many :matchings,				:dependent => :destroy, :foreign_key => "applicant_id"
    has_many :jobs,						:class_name => "Post", 	through: :matchings,	:source => "applicant"
    has_many :devices, 					:class_name => "Device", 	:foreign_key => "owner_id"
    has_one  :score,            :dependent => :destroy, :foreign_key => "owner_id", autosave: true
    has_one  :answered_questions, class_name: "QuestionHistory", :foreign_key => "owner_id", :dependent => :destroy, autosave: true
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

    validates_uniqueness_of :contact_number, allow_nil: true

    def confirmation_required?
        if username.include? "(seed)"
            false
        else
            !confirmed?
        end
    end

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

    def issue_badges
        issue_lovable_badge
        issue_socialbutterfly_badge
    end

    def issue_lovable_badge
        owner_badges = obtained_badges
        unless owner_badges.include? "lovable"
            if good_rating > 4
                owner_badges << "lovable"
                obtained_badges = owner_badges
                self.save
            end
        end 
    end

    def issue_socialbutterfly_badge
        owner_badges = obtained_badges
        unless owner_badges.include? "socialbutterfly"
            if referred_users > 4
                owner_badges << "socialbutterfly"
                obtained_badges = owner_badges
                self.save
            end
        end
    end
end