class DanbooruLogger
  def self.log(exception, expected: false, **params)
    if expected
      Rails.logger.info("#{exception.class}: #{exception.message}")
    else
      backtrace = Rails.backtrace_cleaner.clean(exception.backtrace).join("\n")
      Rails.logger.error("#{exception.class}: #{exception.message}\n#{backtrace}")
    end

    if defined?(::NewRelic) && !expected
      ::NewRelic::Agent.notice_error(exception, expected: expected, custom_params: params)
    end
  end

  def self.initialize(user, remote_ip)
    return unless defined?(::NewRelic)

    ::NewRelic::Agent.add_custom_attributes({ "user.id" => user.id, "user.name" => user.name, "user.ip" => remote_ip })
  end
end
