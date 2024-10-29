class AddPlatformUrlToModel < ActiveRecord::Migration[7.1]
  def change
    add_column :models, :platform_url, :string
  end
end
