class AddTwToUsers < ActiveRecord::Migration
  def change
    add_column :users, :name, :string
    add_column :users, :org, :string
  end
end
