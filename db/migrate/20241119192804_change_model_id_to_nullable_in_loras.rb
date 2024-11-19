class ChangeModelIdToNullableInLoras < ActiveRecord::Migration[7.1]
  def change
    change_column_null :loras, :model_id, true
  end
end
