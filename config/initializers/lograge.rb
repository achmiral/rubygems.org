if Rails.env.production? || Rails.env.staging?
  Rails.application.configure do
    # Enable lograge
    config.lograge.enabled = true

    # Use (Logstash flavored) JSON
    config.lograge.formatter = Lograge::Formatters::Logstash.new

    # The new logs are shipped to stdout for collection
    config.lograge.logger = ActiveSupport::Logger.new(STDOUT)

    # Add custom fields
    config.lograge.custom_options = lambda do |event|
      case
      when event.payload[:status] == 200
        level = "INFO"
      when event.payload[:status] == 302
        level = "WARN"
      else
        level = "ERROR"
      end
      {
        source: "unicorn",
        level: level,
        params: event.payload[:params].except('controller', 'action', 'format', 'utf8'),
        client_ip: event.payload[:client_ip],
        user_agent: event.payload[:user_agent],
        dest_host: event.payload[:dest_host],
        request_id: event.payload[:request_id]
      }
    end
  end
end
