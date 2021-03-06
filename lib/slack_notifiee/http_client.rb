# frozen_string_literal: true

require 'time'

module SlackNotifiee
  module HttpClient
    def post(uri, params)
      payload = JSON.parse(params[:payload])
      notification_content = payload.merge(webhook_url: uri, datetime: Time.now.iso8601(6))

      SlackNotifiee.store_notification(notification_content)
    end

    module_function :post
  end
end
