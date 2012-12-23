class CreateTasks < ActiveRecord::Migration
  def change
    create_table :tasks do |t|
      t.string :name
      t.string :content
      t.boolean :done
      t.date :due
      t.integer :list_id

      t.timestamps
    end
  end
end
