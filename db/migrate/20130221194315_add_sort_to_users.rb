class AddSortToUsers < ActiveRecord::Migration
  def change
    add_column :users, :sortby_all, :string, default: "id"
    add_column :users, :sortby_week, :string, default: "id"
    add_column :users, :sortby_today, :string, default: "id"
  end
end
