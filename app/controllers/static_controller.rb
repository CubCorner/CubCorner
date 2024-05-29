# frozen_string_literal: true

class StaticController < ApplicationController
  respond_to :text, only: %i[robots]

  def privacy
    @page = view_context.safe_wiki("help:privacy_policy")
  end

  def terms_of_service
    @page = view_context.safe_wiki("help:terms_of_service")
  end

  def contact
    @page = view_context.safe_wiki("help:contact")
  end

  def takedown
    @page = view_context.safe_wiki("help:takedown")
  end

  def staff
    @page = view_context.safe_wiki("help:staff")
  end

  def not_found
    render("static/404", formats: [:html], status: 404)
  end

  def error
  end

  def site_map
  end

  def home
    render(layout: "blank")
  end

  def theme
  end

  def toggle_mobile_mode
    if CurrentUser.is_member?
      user = CurrentUser.user
      user.disable_responsive_mode = !user.disable_responsive_mode
      user.save
    elsif cookies[:nmm]
      cookies.delete(:nmm)
    else
      cookies.permanent[:nmm] = "1"
    end
    redirect_back(fallback_location: posts_path)
  end

  def robots
    expires_in(1.hour, public: true)
  end
end
