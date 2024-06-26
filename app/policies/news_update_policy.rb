# frozen_string_literal: true

class NewsUpdatePolicy < ApplicationPolicy
  def create?
    user.is_admin?
  end

  def update?
    user.is_admin?
  end

  def permitted_attributes
    %i[message]
  end
end
