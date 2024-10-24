class CreateRendersLoras < ActiveRecord::Migration[7.1]
  def change
    create_table :renders_loras do |t|
      t.references :render, null: false, foreign_key: true
      t.references :lora, null: false, foreign_key: true
      t.float :scale

      t.timestamps
    end
  end
end
