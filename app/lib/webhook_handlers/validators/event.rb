# frozen_string_literal: true

module WebhookHandlers
  module Validators
    class Event
      def initialize(payload, event_type)
        @payload     = payload
        @event_type  = event_type
        @result      = { error_code: nil }
      end

      def validate
        valid_event_type? && valid_event_payload? && valid_repository?
      end

      private

      def valid_event_type?
        %i[commits pull_request release].include?(@event_type)
      end

      def valid_event_payload?
        case @event_type
        when :commits
          @payload.key?(:commits)
        when :pull_request
          @payload[:pull_request]&.key?(:commits)
        when :release
          @payload[:release]&.key?(:commits) && unpublished_release?
        end
      end

      def valid_repository?
        @payload[:repository]&.key?(:name)
      end

      def unpublished_release?
        !Release.joins(:repository)
                .exists?(tag_name: @payload[:release][:tag_name], repositories: { name: @payload[:repository][:name] })
      end
    end
  end
end
