class AddNestedSetsToLists < ActiveRecord::Migration
  def change
    change_table :lists do |t|
      t.integer :parent_id
      t.integer :lft
      t.integer :rgt
    end
  end
end
