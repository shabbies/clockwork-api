class ChangeBadgesStructure < ActiveRecord::Migration
  def change
	add_column :badges, :badge_id, :string
	add_column :users,	:obtained_badges, :text, array: true, default: []
  end
end
