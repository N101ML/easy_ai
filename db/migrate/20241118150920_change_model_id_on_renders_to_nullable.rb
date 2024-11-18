class ChangeModelIdOnRendersToNullable < ActiveRecord::Migration[7.1]
  def change
    change_column_null :renders, :model_id, true
  end
end
