module ListsHelper
  def all_lists
    current_user.lists.arrange
  end
end
