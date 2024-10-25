class RenameRendersLorasToRenderLoras < ActiveRecord::Migration[7.1]
  def change
    rename_table :renders_loras, :render_loras
  end
end
