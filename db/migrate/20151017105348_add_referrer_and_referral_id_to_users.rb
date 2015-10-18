class AddReferrerAndReferralIdToUsers < ActiveRecord::Migration
  def change
  	add_column :users,	:referral_id,		:string
  	add_column :users,	:referred_users,	:int,		:default => 0
  	add_column :users,	:nric,				:string
  	add_column :users,	:referred_by,		:string
  end
end
