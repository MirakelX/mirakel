class AddSortToLists < ActiveRecord::Migration
  def change
    add_column :lists, :sortby, :string, default: "id"
  end
end
