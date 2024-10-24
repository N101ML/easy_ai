class CreateModels < ActiveRecord::Migration[7.1]
  def change
    create_table :models do |t|
      t.text :name
      t.text :url_src

      t.timestamps
    end
  end
end
