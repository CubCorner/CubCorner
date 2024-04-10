# frozen_string_literal: true

class TagVersionPolicy < ApplicationPolicy
  def permitted_search_params
    %i[tag updater_id updater_name]
  end
end
