module Messages
  class ReceivedProcessorJob < ApplicationJob
    attr_reader :message

    def perform(message)
      @message = message

      # Process response message in context of requested volunteer associations waiting for response
      RequestedVolunteer.where(volunteer_id: message.volunteer_id, state: :notified).each do |requested_volunteer|
        return invalid_response unless valid_response?

        Admin::Requests::VolunteerResponseProcessor.new(requested_volunteer, response).perform
        confirm_response requested_volunteer
        mark_message_as_read
      rescue Admin::Requests::CapacityExceededError
        capacity_exceeded_response requested_volunteer
      end
    end

    private

    def valid_response?
      !response.nil?
    end

    def invalid_response
      volunteer = Volunteer.find(@message.volunteer_id)
      text      = I18n.t('sms.request.unrecognized')

      SmsService.send_text volunteer.phone, text
    end

    def capacity_exceeded_response(requested_volunteer)
      create_message I18n.t('sms.request.over_capacity', organisation: requested_volunteer.request.organisation.name)
    end

    def mark_message_as_read
      @message.mark_as_read
    end

    def confirm_response(requested_volunteer)
      if requested_volunteer.accepted?
        create_message I18n.t('sms.request.confirmed', organisation: requested_volunteer.request.organisation.name)
      else
        create_message I18n.t('sms.request.rejected', organisation: requested_volunteer.request.organisation.name)
      end
    end

    def create_message(text)
      Message.outgoing.sms.message_type_other.create! text: text,
                                                      volunteer_id: message.volunteer_id
    end

    def response
      return @response if defined? @response

      normalized_message = message.text.strip.downcase
      @response = true if normalized_message == 'ano'
      @response = false if normalized_message == 'ne'
      @response
    end
  end
end