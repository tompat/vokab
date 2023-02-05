class AddLastCorrectAnswerAtAndLastBadAnswerAtToItems < ActiveRecord::Migration[6.0]
  def change
    add_column :items, :last_correct_answer_at, :datetime
    add_column :items, :last_bad_answer_at, :datetime
  end
end
