class Task < ActiveRecord::Base
  attr_accessible :content, :done, :due, :list_id, :name
end
