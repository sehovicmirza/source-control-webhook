# frozen_string_literal: true

module WebhookHandlers
  class VersionControl
    def initialize(params, event_type)
      @params     = params
      @event_type = event_type
      @result     = { error_code: nil }
    end

    def handle_event
      if event_validator.validate
        send handle_method
      else
        @result[:error_code] = :invalid_event
      end

      @result
    end

    def handle_commits
      commits = find_or_create_commits(@params[:commits])
      return if @result[:error_code]

      result = ticket_tracking_integrator.process(commits)
      @result[:error_code] = :publish_failed if result[:status] == :failed
    end

    def handle_pull_request
      pull_request = create_pull_request(@params[:pull_request])
      return @result[:error_code] = :invalid_payload unless pull_request&.valid?

      commits = find_or_create_commits(@params[:pull_request][:commits])
      return pull_request.destroy if @result[:error_code]

      if ticket_tracking_integrator.process(commits)[:status] == :failed
        pull_request.destroy
        @result[:error_code] = :publish_failed
      else
        pull_request.commits = commits
        pull_request.save
      end
    end

    def handle_release
      release = create_release(@params[:release])
      return @result[:error_code] = :invalid_payload unless release&.valid?

      commits = find_or_create_commits(@params[:release][:commits], release)
      return release.destroy if @result[:error_code]

      return unless ticket_tracking_integrator.process(commits)[:status] == :failed

      release.destroy
      @result[:error_code] = :publish_failed
    end

    protected

    def event_validator
      @event_validator ||= Validators::Event.new(@params, @event_type)
    end

    def event_parser
      @event_parser ||= Parsers::Event.new(@params)
    end

    def ticket_tracking_integrator
      @ticket_tracking_integrator ||= ExternalIntegrations::TicketTracking.new(@event_type)
    end

    private

    def handle_method
      @handle_method ||= "handle_#{@event_type}"
    end

    def find_or_create_commits(payload, release = nil)
      ActiveRecord::Base.transaction do
        payload.map do |commit_params|
          commit_attributes = event_parser.build_commit_attributes(commit_params, release)
          commit = Commit.find_or_create_by(commit_attributes) if commit_attributes

          unless commit&.valid?
            @result[:error_code] = :invalid_payload
            raise ActiveRecord::Rollback
          end

          commit
        end
      end
    end

    def create_release(payload)
      release_attributes = event_parser.build_release_attributes(payload)
      Release.create(release_attributes) if release_attributes
    end

    def create_pull_request(payload)
      pull_request_attributes = event_parser.build_pull_request_attributes(payload)
      PullRequest.create(pull_request_attributes) if pull_request_attributes
    end
  end
end
