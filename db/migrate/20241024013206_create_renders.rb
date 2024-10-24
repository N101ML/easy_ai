class CreateRenders < ActiveRecord::Migration[7.1]
  def change
    create_table :renders do |t|
      t.string :type
      t.float :guidance_scale
      t.references :model, null: false, foreign_key: true

      t.timestamps
    end
  end
end
