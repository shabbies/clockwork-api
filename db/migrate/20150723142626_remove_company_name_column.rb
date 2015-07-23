class RemoveCompanyNameColumn < ActiveRecord::Migration
  def change
  	remove_column :users, :company_name
  end
end
