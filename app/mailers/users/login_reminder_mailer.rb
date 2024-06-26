# frozen_string_literal: true

module Users
  class LoginReminderMailer < ApplicationMailer
    default from: PawsMovin.config.mail_from_addr, content_type: "text/html"

    def notice(user)
      @user = user
      if user.email.present?
        mail(to: user.email, subject: "#{PawsMovin.config.app_name} login reminder")
      end
    end
  end
end
