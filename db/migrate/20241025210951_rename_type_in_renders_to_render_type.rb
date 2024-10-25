class RenameTypeInRendersToRenderType < ActiveRecord::Migration[7.1]
  def change
    rename_column :renders, :type, :render_type
  end
end
