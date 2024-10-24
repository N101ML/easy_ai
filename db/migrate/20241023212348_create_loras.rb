class CreateLoras < ActiveRecord::Migration[7.1]
  def change
    create_table :loras do |t|
      t.text :name
      t.text :url_src
      t.float :scale
      t.text :trigger
      t.references :model, null: false, foreign_key: true

      t.timestamps
    end
  end
end
