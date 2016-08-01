class Matching < ActiveRecord::Base
	after_save :format_check_in, if: :status_changed?
  after_create :add_to_chatroom
	serialize :job_timings

	belongs_to :applicant, :class_name => "User", :foreign_key => "applicant_id"
	belongs_to :post

	default_scope { where.not(status: "withdrawn") }

	private

  def format_check_in
    if status == "hired" && job_timings == nil
    	post = self.post
    	duration = post.duration
    	check_in_date_hash = Hash.new
    	for i in 0...duration
    		time_hash = { "check_in" => "", "check_out" => "", "day_wage" => 0 }
    		check_in_date_hash[(post.job_date + i).strftime("%d-%m-%Y")] = time_hash
    	end 
    	self.job_timings = check_in_date_hash
    	save!
    end
  end

  def add_to_chatroom
    chatroom = Chatroom.where(post_id: post_id).first
    unless chatroom
      chatroom = Chatroom.new(post_id: post_id)
    end
    begin
      chatroom.save
      ChatroomParticipant.create!(chatroom_id: chatroom.id, user_id: applicant_id, post_id: chatroom.post_id)
    rescue ActiveRecord::RecordNotUnique
    end
  end
end
