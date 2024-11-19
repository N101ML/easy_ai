class UpdateLorasForeignKeyOnDelete < ActiveRecord::Migration[7.1]
  def change
    remove_foreign_key :loras, :models
    add_foreign_key :loras, :models, on_delete:  :nullify
  end
end
