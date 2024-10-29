class AddPlatformUrlToLora < ActiveRecord::Migration[7.1]
  def change
    add_column :loras, :platform_url, :string
  end
end
