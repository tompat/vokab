class CreateItems < ActiveRecord::Migration[6.0]
  def change
    create_table :items do |t|
      t.text    :text_1
      t.text    :text_2

      t.timestamps
    end
  end
end
