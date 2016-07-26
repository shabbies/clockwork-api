class Chat < Grape::API
	before do
		token = request.headers["Authentication-Token"]
    	@user = User.find_by_email_and_authentication_token(params[:email],token)
    	error!('Unauthorised - Invalid authentication token', 401) unless @user
	end

	resource :chat do	

  	# START NEW CHATROOM METHOD #
  	desc "new chatroom", {
  	headers: {
		    "Authentication-Token" => {
		      description: "Authentication Token issued upon sign in",
		      required: true
		    }
 			}
		}
    params do
			requires :post_id,			type: Integer
			requires :email,				type: String
			requires :participants,	type: String, 	desc: "User IDs separated by ,"
		end
    post :create_chatroom, 
    	:http_codes => [
			[401, "Unauthorised - Invalid authentication token"], 
			[400, "	(1)Bad Request - The post ID is invalid | 
							(2)Bad Request - The user ID is invalid |
							(3)Bad Request - The chatroom already exists for the post"],
			[200, "IGNORE NO SUCH CODE"],
			[201, "Chatroom successfully created"]
		] do
			post = Post.where(id: params[:post_id]).first
			error!("Bad Request - The post ID is invalid", 400) unless post

			participants = params[:participants].split(",")
			begin
				ChatroomParticipant.transaction do
					chatroom = Chatroom.create(post_id: post.id)
					participants.each do |id|
						participant = User.where(id: id).first
						unless participant
							raise ActiveRecord::Rollback
						end
						ChatroomParticipant.create(chatroom_id: chatroom.id, user_id: id, post_id: post.id)
					end
				end
			rescue
				error!("Bad Request - The chatroom already exists for the post", 400)
			end

			chatroom = Chatroom.where(post_id: post.id).first
			if chatroom
				status 201
				"Chatroom successfully created"
			else
				error!("Bad Request - The user ID is invalid", 400)
			end
  	end
  	# END NEW CHATROOM METHOD #

  	# START GET CHATROOM MESSAGES METHOD #
  	desc "get chatroom messages", {
  	headers: {
		    "Authentication-Token" => {
		      description: "Authentication Token issued upon sign in",
		      required: true
		    }
 			}
		}
    params do
			requires :post_id,			type: Integer
			requires :email,				type: String
		end
    post :get_messages, 
    	:http_codes => [
			[401, "Unauthorised - Invalid authentication token"], 
			[400, "(1)Bad Request - The post ID is invalid"],
			[201, "Messages retrieved successfully"]
		] do
			post = Post.where(id: params[:post_id]).first
			error!("Bad Request - The post ID is invalid", 400) unless post

			messages = ChatMessage.where(chatroom_id: post.id).all
			
			status 200
			messages.to_json
  	end
  	# END NEW CHATROOM METHOD #

  	# START NEW MESSAGES METHOD #
  	desc "post new chatroom messages", {
  	headers: {
		    "Authentication-Token" => {
		      description: "Authentication Token issued upon sign in",
		      required: true
		    }
 			}
		}
    params do
			requires :post_id,			type: Integer
			requires :email,				type: String
			requires :content,			type: String
		end
    post :new_message, 
    	:http_codes => [
			[401, "Unauthorised - Invalid authentication token"], 
			[400, "(1)Bad Request - The post ID is invalid |
						 (2)Bad Request - The content cannot be blank"],
			[200, "IGNORE NO SUCH CODE"],
			[201, "Message successfully created"]
		] do
			post = Post.where(id: params[:post_id]).first
			error!("Bad Request - The post ID is invalid", 400) unless post
			error!("Bad Request - The content cannot be blank", 400) if params[:content].blank?

			ChatMessage.create!(sender_id: @user.id, chatroom_id: post.id, content: params[:content])
			
			status 200
			"Message successfully created"
  	end
  	# END NEW CHATROOM METHOD #

  	# START GET ALL JS CHATROOMS METHOD #
  	desc "get js chatrooms", {
  	headers: {
		    "Authentication-Token" => {
		      description: "Authentication Token issued upon sign in",
		      required: true
		    }
 			}
		}
    params do
			requires :email,				type: String
		end
    post :get_js_chatrooms, 
    	:http_codes => [
			[401, "Unauthorised - Invalid authentication token"], 
			[200, "IGNORE NO SUCH CODE"],
			[201, "Message successfully created"]
		] do
			chatrooms = ChatroomParticipant.where(user_id: @user.id).all.order(:created_at).pluck(:post_id)
			returning_arr = []
			chatrooms.each do |chatroom|
				new_hash = {}
				post = Post.find(chatroom)
				new_hash[:avatar] = post.owner.avatar_path
				new_hash[:name] = post.owner.username
				new_hash[:job] = post.header
				new_hash[:start_date] = post.job_date
				new_hash[:end_date] = post.end_date
				new_hash[:chatroom_id] = chatroom
				returning_arr << new_hash
			end
			
			status 200
			returning_arr.to_json
  	end
  	# END GET ALL JS CHATROOMS METHOD #
	end
end