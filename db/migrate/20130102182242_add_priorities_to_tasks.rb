class AddPrioritiesToTasks < ActiveRecord::Migration
  def change
    add_column :tasks, :priority, :integer, default: 0
  end
end
