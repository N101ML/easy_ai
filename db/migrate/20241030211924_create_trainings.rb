class CreateTrainings < ActiveRecord::Migration[7.1]
  def change
    create_table :trainings do |t|
      t.string :name
      t.references :model, null: false, foreign_key: true

      t.timestamps
    end
  end
end
