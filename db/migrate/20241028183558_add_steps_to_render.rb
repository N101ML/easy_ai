class AddStepsToRender < ActiveRecord::Migration[7.1]
  def change
    add_column :renders, :steps, :integer
  end
end
