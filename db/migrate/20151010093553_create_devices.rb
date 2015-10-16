class CreateDevices < ActiveRecord::Migration
  def change
    create_table :devices do |t|
    	t.column 'owner_id', 	:integer 
    	t.column 'device_id', 	:string
    	t.column 'status',		:string,	default: "subscribed"
    	t.column 'type',		:string

      t.timestamps null: false
    end
  end
end
