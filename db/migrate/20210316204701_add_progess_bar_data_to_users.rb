class AddProgessBarDataToUsers < ActiveRecord::Migration[6.0]
  def change
    add_column :users, :progress_bar_data, :json, default: []
  end
end
