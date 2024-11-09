class AddOutputsToRender < ActiveRecord::Migration[7.1]
  def change
    add_column :renders, :num_outputs, :integer
  end
end
