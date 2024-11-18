class AddBaseToModels < ActiveRecord::Migration[7.1]
  def change
    add_column :models, :base, :string
  end
end
