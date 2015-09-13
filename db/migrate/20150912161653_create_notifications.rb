class CreateNotifications < ActiveRecord::Migration
  def change
    create_table :notifications do |t|
      t.integer :sender_id,		:index => true
      t.integer	:receiver_id, :index => true
      t.string	:content
      t.string	:status,		  :default => "unread"
      t.string  :avatar_path, :default => nil

      t.timestamps null: false
    end
    
    add_foreign_key :notifications, :users, :column => :sender_id
    add_foreign_key :notifications, :users, :column => :receiver_id
  end
end
