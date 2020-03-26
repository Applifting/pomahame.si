module Api
  module Volunteer
    class RequestResponse
      def initialize(volunteer, request, params)
        @volunteer = volunteer
        @request = request
        @params = params
      end

      def perform
        validate_params!
        validate_access!
        @request.with_lock do
          validate_capacity!
          requested_volunteer.update! state: resolve_state
        end
      end

      private

      def requested_volunteer
        @requested_volunteer ||= RequestedVolunteer.find_by request: @request, volunteer: @volunteer
      end

      def resolve_state
        ActiveModel::Type::Boolean.new.cast(@params[:accept]) ? :accepted : :rejected
      end

      def validate_capacity!
        return if @request.requested_volunteers.accepted.size < @request.required_volunteer_count

        raise CapacityExceededError
      end

      def validate_access!
        return if requested_volunteer.present?

        raise AuthorisationError
      end

      def validate_params!
        return if @params.key?(:accept)

        raise InvalidArgumentError
      end
    end
  end
end

class CapacityExceededError < StandardError

end