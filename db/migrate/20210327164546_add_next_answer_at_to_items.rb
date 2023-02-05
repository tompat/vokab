class AddNextAnswerAtToItems < ActiveRecord::Migration[6.0]
  def change
    add_column :items, :next_answer_at, :datetime
  end
end
