class AddAttributesToTraining < ActiveRecord::Migration[7.1]
  def change
    add_column :trainings, :steps, :integer
    add_column :trainings, :optimizer, :string
    add_column :trainings, :destination, :string
    add_column :trainings, :trigger_word, :string
    add_column :trainings, :resolution, :string
  end
end
