module TasksHelper
  def getOrder(list)
    case list.sortby
    when "priority"
      return "priority DESC"
    when "due"
      return "due DESC"
    else
      return "id ASC"
    end
  end
end
