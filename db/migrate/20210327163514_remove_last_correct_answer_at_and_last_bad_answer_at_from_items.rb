class RemoveLastCorrectAnswerAtAndLastBadAnswerAtFromItems < ActiveRecord::Migration[6.0]
  def change
    remove_column :items, :last_correct_answer_at
    remove_column :items, :last_bad_answer_at
  end
end
