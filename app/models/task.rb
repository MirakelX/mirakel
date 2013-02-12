# == Schema Information
#
# Table name: tasks
#
#  id         :integer          not null, primary key
#  name       :string(255)
#  content    :string(255)
#  done       :boolean          default(FALSE)
#  due        :date
#  list_id    :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  parent_id  :integer
#  lft        :integer
#  rgt        :integer
#  priority   :integer          default(0)
#

class Task < ActiveRecord::Base
  attr_accessible :content, :done, :due, :list_id, :name, :priority
  belongs_to :list

  validates :name, presence: true


  # Get all Task by due Date
  def self.getByDate(lists,range)
      tasks=Array.new(1)
      done_tasks=Array.new(1)
      lists.each do |list|
        tasks=tasks.concat(list.tasks.where(done: false, due: range))
      end
      tasks=tasks[1..-1]
      return tasks
  end
end
