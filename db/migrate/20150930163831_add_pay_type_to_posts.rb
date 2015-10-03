class AddPayTypeToPosts < ActiveRecord::Migration
  def change
  	add_column :posts, :pay_type, :string, :default => "hour"
  end
end
