class AddSortToLists < ActiveRecord::Migration
  def change
    add_column :lists, :sortby, :string
  end
end
