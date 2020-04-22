# frozen_string_literal: true

module WebhookHandlers
  module Parsers
    class Event
      def initialize(params)
        @params = params
      end

      def build_pull_request_attributes(payload)
        attributes = append_associations(payload)
        attributes[:head_sha] = payload[:head][:sha] if payload[:head]

        attributes.except(:commits, :id, :created_at, :updated_at, :head)
      end

      def build_release_attributes(payload)
        attributes = append_associations(payload, :author)
        attributes[:released_at] = @params[:released_at]

        attributes.except(:commits, :id)
      end

      def build_commit_attributes(payload, release = nil)
        attributes = append_associations(payload, :author)
        attributes[:release] = release

        attributes
      end

      private

      def append_associations(payload, user_key = :user)
        user = User.find_or_create_by(payload.delete(user_key)) if payload[user_key]
        return unless user&.valid?

        repository = Repository.find_or_create_by(@params[:repository]) if @params[:repository]
        return unless repository&.valid?

        payload[:user] = user
        payload[:repository] = repository

        payload
      end
    end
  end
end
