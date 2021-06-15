# frozen_string_literal: true

# Policy to determine if account can view a restaurant
class CommentPolicy
  def initialize(account, comment, auth_scope = nil)
    @account = account
    @comment = comment
    @auth_scope = auth_scope
  end

  def can_view?
    can_read? && (account_owns_restaurant? || account_collaborates_on_restaurant?)
  end

  def can_edit?
    can_write? && (account_owns_restaurant? || account_collaborates_on_restaurant?)
  end

  def can_delete?
    can_write? && (account_owns_restaurant? || account_collaborates_on_restaurant?)
  end

  def summary
    {
      can_view: can_view?,
      can_edit: can_edit?,
      can_delete: can_delete?
    }
  end

  private

  def can_read?
    @auth_scope ? @auth_scope.can_read?('comments') : false
  end

  def can_write?
    @auth_scope ? @auth_scope.can_write?('comments') : false
  end

  def account_owns_restaurant?
    @comment.restaurant.owner == @account
  end

  def account_collaborates_on_restaurant?
    @comment.restaurant.collaborators.include?(@account)
  end
end
