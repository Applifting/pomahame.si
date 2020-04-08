module Messages
  class ReceiverJob < ApplicationJob
    queue_as :receiver_queue

    around_perform do |job, block|
      block.call
    rescue StandardError => e
      Raven.capture_exception e
    ensure
      Messages::ReceiverJob.perform_later
    end

    def perform
      Rails.logger.debug 'Performing MessageReceiverJob'

      if Rails.env.production? || ENV['RECEIVE_MESSAGES'] == 'true'
        SmsService.receive
      else
        puts 'Calling receiver service'
      end
    end
  end
end
