class AddAnswersHistoryToItems < ActiveRecord::Migration[6.0]
  def change
    add_column :items, :answers_history, :json, default: []
  end
end
