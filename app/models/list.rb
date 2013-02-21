# == Schema Information
#
# Table name: lists
#
#  id         :integer          not null, primary key
#  name       :string(255)
#  user_id    :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  parent_id  :integer
#  lft        :integer
#  rgt        :integer
#

class List < ActiveRecord::Base
  attr_accessible :name, :user_id, :sortby
  has_many :tasks, foreign_key: "list_id"
  acts_as_nested_set

  validates :name, presence: true

  before_destroy { |record| 
    puts "\""*1000; 
    puts record
    Task.destroy_all( "list_id=#{record.id}"); 
  }
  # Creates an JSON-compatible tree
  # Idea from http://stackoverflow.com/questions/9944005/how-to-generate-json-tree-from-ancestry
  def self.json_tree(nodes)
    nodes.map do |node, sub_nodes|
      {
        id: node.id,
        name: node.name,
        user_id: node.user_id,
        created_at: node.created_at,
        updated_at: node.updated_at,
        children: json_tree(sub_nodes).compact
      }
    end
    
  end

end
