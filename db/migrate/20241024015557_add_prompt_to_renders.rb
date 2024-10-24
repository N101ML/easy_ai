class AddPromptToRenders < ActiveRecord::Migration[7.1]
  def change
    add_column :renders, :prompt, :text
  end
end
