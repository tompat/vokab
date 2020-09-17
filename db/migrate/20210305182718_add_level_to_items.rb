class AddLevelToItems < ActiveRecord::Migration[6.0]
  def change
    add_column :items, :level, :integer, default: 0
  end
end
