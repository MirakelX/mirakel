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
  attr_accessible :name, :user_id
  has_many :tasks, foreign_key: "list_id"
  acts_as_nested_set

  validates :name, presence: true

end
