class CreateChatMessages < ActiveRecord::Migration
  def change
    create_table :chat_messages do |t|
    	t.belongs_to 	:sender,		:class_name => "User", :index => true
    	t.belongs_to 	:chatroom,	:index => true
    	t.string 			:content, 	:null => false

      t.timestamps null: false
    end
  end
end
