module ListsHelper
  def all_lists
    current_user.lists
  end
end
