module Messages
  class ReceiverJob < ApplicationJob
    queue_as :receiver_queue

    REPEAT_COUNT = 30
    TIMEOUT = 30 # seconds

    around_perform do |job, block|
      block.call
    rescue StandardError => e
      Raven.capture_exception e
    ensure
      Messages::ReceiverJob.set(wait: (rand * 10).seconds).perform_later unless already_enqueued? || already_scheduled?
    end

    def perform
      Rails.logger.debug 'Performing MessageReceiverJob'
      start_time = Time.current

      counter = 0
      while (counter < REPEAT_COUNT) || ((Time.current - start_time) < TIMEOUT.seconds)
        break if already_enqueued? || already_scheduled?

        counter += 1
        receive_sms
      end
    end

    private

    def receive_sms
      if Rails.env.production? || ENV['RECEIVE_MESSAGES'] == 'true'
        SmsService.receive
      else
        puts 'Calling receiver service'
        sleep 0.1
      end
    end

    def already_scheduled?
      Sidekiq::ScheduledSet.new.scan("Messages::ReceiverJob").any?
    end

    def already_enqueued?
      Sidekiq::Queue.new('receiver_queue').any?
    end
  end
end
