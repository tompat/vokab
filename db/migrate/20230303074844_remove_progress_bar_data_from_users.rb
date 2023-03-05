class RemoveProgressBarDataFromUsers < ActiveRecord::Migration[7.0]
  def change
    remove_column :users, :progress_bar_data
  end
end
