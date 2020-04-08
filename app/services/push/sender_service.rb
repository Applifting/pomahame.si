module Push
  class SenderService
    def initialize(payload_data, notification_data, receivers)
      @payload_data = payload_data
      @notification_data = notification_data
      @receivers = receivers
    end

    def perform
      n = Rpush::Gcm::Notification.new
      n.app = Rpush::Gcm::App.find_by_name(ENV['PUSH_APP_NAME'])
      n.registration_ids = @receivers
      n.data = @payload_data
      n.priority = 'normal'
      n.content_available = true
      n.notification = @notification_data
      n.save!
    end
  end
end