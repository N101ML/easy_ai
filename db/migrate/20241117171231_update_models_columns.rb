class UpdateModelsColumns < ActiveRecord::Migration[7.1]
  def change
    rename_column :models, :url_src, :platform_source
    add_column :models, :company, :string
    remove_column :models, :platform_url, :string
    remove_column :models, :base, :string
  end
end
