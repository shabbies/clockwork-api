class AddQuizCountAndQuizScoreToScore < ActiveRecord::Migration
  def change
  	add_column :scores, :quiz_count, :integer, default: 0
  	add_column :scores, :quiz_score, :float, default: 0
  end
end
