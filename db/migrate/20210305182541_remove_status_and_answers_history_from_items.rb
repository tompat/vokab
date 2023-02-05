class RemoveStatusAndAnswersHistoryFromItems < ActiveRecord::Migration[6.0]
  def change
    remove_column :items, :status
    remove_column :items, :answers_history
  end
end
