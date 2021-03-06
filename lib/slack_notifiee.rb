# frozen_string_literal: true

require 'fileutils'
require 'pathname'
require 'ulid'

require_relative 'slack_notifiee/notification'
require_relative 'slack_notifiee/slack_notifier_extension'
require_relative 'slack_notifiee/version'

module SlackNotifiee
  def enable
    _reset_storage
    _override_http_client
  end

  def store_notification(notification)
    filepath = _storage_path + "#{ULID.generate}.json"
    File.open(filepath, 'w') { |file| JSON.dump(notification, file) }
  end

  def notifications
    _storage_path.children.sort.map(&:read).map do |notification_content|
      ::SlackNotifiee::Notification.build_from_json(notification_content)
    end
  end

  def _storage_path
    Pathname('tmp/slack-notifiee')
  end

  def _reset_storage
    ::FileUtils.mkdir_p(_storage_path)
    ::FileUtils.rm_f(_storage_path.children)
  end

  def _override_http_client
    ::Slack::Notifier.class_eval { prepend ::SlackNotifiee::SlackNotifierExtension }
  end

  module_function :enable, :store_notification, :notifications, :_storage_path, :_reset_storage, :_override_http_client
  private_class_method :_storage_path, :_reset_storage, :_override_http_client
end
