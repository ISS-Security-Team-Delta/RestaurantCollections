# frozen_string_literal: true

# Policy to determine if account can view a project
class CommentPolicy
  def initialize(account, comment)
    @account = account
    @comment = comment
  end

  def can_view?
    account_owns_restaurant? || account_collaborates_on_restaurant?
  end

  def can_edit?
    account_owns_restaurant? || account_collaborates_on_restaurant?
  end

  def can_delete?
    account_owns_restaurant? || account_collaborates_on_restaurant?
  end

  def summary
    {
      can_view: can_view?,
      can_edit: can_edit?,
      can_delete: can_delete?
    }
  end

  private

  def account_owns_restaurant?
    @comment.restaurant.owner == @account
  end

  def account_collaborates_on_restaurant?
    @document.restaurant.collaborators.include?(@account)
  end
end
