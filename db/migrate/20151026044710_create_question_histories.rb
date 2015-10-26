class CreateQuestionHistories < ActiveRecord::Migration
  def change
    create_table :question_histories do |t|
    	t.integer 	:owner_id, index: true
    	t.text		:clean_up, array: true, default: []
    	t.text		:order_taking, array: true, default: []
    	t.text		:barista, array: true, default: []
    	t.text		:selling, array: true, default: []
    	t.text		:kitchen, array: true, default: []
    	t.text		:bartender, array: true, default: []
    	t.text		:service, array: true, default: []
    	t.text		:cashier, array: true, default: []

      	t.timestamps null: false
    end

    add_foreign_key :question_histories, :users, :column => :owner_id
  end
end
