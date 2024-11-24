class AddFineTuneToRenders < ActiveRecord::Migration[7.1]
  def change
    add_reference :renders, :fine_tune, foreign_key: { on_delete: :nullify }, null: true
  end
end
