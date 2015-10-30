class UpdateReferredByInUsers < ActiveRecord::Migration
  def change
  	remove_column :users, :referred_by
  	add_column :users, :referred_by, :string, default: nil
  end
end
