class CreateScores < ActiveRecord::Migration
  def change
    create_table :scores do |t|
    	t.integer :service, 		default: 0
      	t.integer :kitchen, 		default: 0
      	t.integer :bartender, 		default: 0
  		t.integer :barista, 		default: 0
      	t.integer :order_taking, 	default: 0
      	t.integer :cashier, 		default: 0
      	t.integer :clean_up, 		default: 0
      	t.integer :selling, 		default: 0

      	t.integer :owner_id,		:index => true

      	t.timestamps null: false
    end

    add_foreign_key :scores, :users, :column => :owner_id
  end
end
