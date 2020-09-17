class AddLevelsEvolutionToUsers < ActiveRecord::Migration[6.0]
  def change
    add_column :users, :levels_evolution, :json, default: {}
  end
end
