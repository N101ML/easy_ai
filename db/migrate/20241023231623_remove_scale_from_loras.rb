class RemoveScaleFromLoras < ActiveRecord::Migration[7.1]
  def change
    remove_column :loras, :scale, :float
  end
end
