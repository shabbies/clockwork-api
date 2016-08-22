class AddCalculatedSalaryToMatchings < ActiveRecord::Migration
  def change
  	add_column :matchings, :salary, :float, :default => 0
  end
end
