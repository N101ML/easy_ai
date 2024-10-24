class AddPlatformToLoras < ActiveRecord::Migration[7.1]
  def change
    add_column :loras, :platform, :string
  end
end
