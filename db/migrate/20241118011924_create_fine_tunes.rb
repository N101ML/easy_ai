class CreateFineTunes < ActiveRecord::Migration[7.1]
  def change
    create_table :fine_tunes do |t|
      t.string :name
      t.string :platform
      t.string :platform_source
      t.string :platform_link
      t.references :model, null: false, foreign_key: true

      t.timestamps
    end
  end
end
