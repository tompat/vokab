class AddReverseItemIdToItems < ActiveRecord::Migration[6.0]
  def change
    add_column :items, :reverse_item_id, :integer
  end
end
