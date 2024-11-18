class AddPlatformLinkToModels < ActiveRecord::Migration[7.1]
  def change
    add_column :models, :platform_link, :string
  end
end
