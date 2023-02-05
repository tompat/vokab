class ChangeLastAnswerAtAndNextAnswerAtToDate < ActiveRecord::Migration[6.0]
  def change
    change_column :items, :last_answer_at, :date
    change_column :items, :next_answer_at, :date
  end
end
