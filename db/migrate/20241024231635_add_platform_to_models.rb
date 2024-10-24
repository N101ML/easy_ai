class AddPlatformToModels < ActiveRecord::Migration[7.1]
  def change
    add_column :models, :platform, :string
  end
end
