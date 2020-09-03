module Admin
  module Requests
    class VolunteerNotifier

      attr_reader :user, :request

      def initialize(user, request)
        @user = user
        @request = request
      end

      def notify_assigned
        request.requested_volunteers.to_be_notified.eager_load(:volunteer).each do |requested_volunteer|
          notification_of_assigned requested_volunteer
        end
      end

      def notify_updated
        request.requested_volunteers.eager_load(:volunteer).each do |requested_volunteer|
          next unless should_receive_push_update? requested_volunteer

          notification_of_updated requested_volunteer
        end
      end

      private

      def notification_of_assigned(requested_volunteer)
        requested_volunteer.pending_notification!
        MessagingService.create_message direction: :outgoing,
                                        message_type: :request_offer,
                                        request: request,
                                        channel: resolve_channel(requested_volunteer),
                                        text: resolve_text(requested_volunteer),
                                        volunteer_id: requested_volunteer.volunteer_id,
                                        creator: user
      end

      def notification_of_updated(requested_volunteer)
        MessagingService.create_message direction: :outgoing,
                                        message_type: :request_update,
                                        request: request,
                                        channel: :push,
                                        text: push_text_updated,
                                        volunteer_id: requested_volunteer.volunteer_id,
                                        creator: user
      end

      def resolve_text(requested_volunteer)
        requested_volunteer.volunteer.push_notifications? ? push_text_assigned : sms_text_assigned
      end

      def resolve_channel(requested_volunteer)
        requested_volunteer.volunteer.push_notifications? ? :push : :sms
      end

      def sms_text_assigned
        I18n.t 'sms.request.offer', identifier: request.identifier, text: request.text
      end

      def push_text_assigned
        I18n.t 'push.notifications.request.new.body', description: request.text,
                                                      organisation: request.organisation.name
      end

      def push_text_updated
        I18n.t 'push.notifications.request.update.body', description: request.text,
                                                      organisation: request.organisation.name
      end

      def should_receive_push_update?(requested_volunteer)
        (requested_volunteer.notified? || requested_volunteer.accepted?) && requested_volunteer.volunteer.push_notifications?
      end
    end
  end
end


rq = RequestedVolunteer.last
user = User.find 2
Admin::Requests::VolunteerNotifier.new(user, rq.request).notify_assigned