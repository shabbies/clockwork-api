class AddGenderAndNationalityToUsers < ActiveRecord::Migration
  def change
  	add_column :users, :gender, "char(1)", :default => nil
  	add_column :users, :nationality, :string, :default => nil
  end
end
