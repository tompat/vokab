class AddLastAnswerAtToItems < ActiveRecord::Migration[6.0]
  def change
    add_column :items, :last_answer_at, :datetime
  end
end
