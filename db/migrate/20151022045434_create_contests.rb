class CreateContests < ActiveRecord::Migration
  def change
    create_table :contests do |t|
    	t.string	:email
    	t.string	:name

      	t.timestamps null: false
    end
  end
end
