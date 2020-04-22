# frozen_string_literal: true

class WebhooksController < ApplicationController
  before_action :validate_params, only: :receive

  ALLOWED_PARAMETERS = {
    user:       %i[name email],
    repository: %i[name],
    commit:     [:sha, :message, :date, author: %i[name email]]
  }.freeze

  def receive
    result = version_control_handler.handle_event
    return render_error result[:error_code] if result[:error_code]

    render nothing: true
  end

  protected

  def version_control_handler
    @version_control_handler ||= WebhookHandlers::VersionControl.new(permitted_params, payload_type)
  end

  def payload_type
    @payload_type ||= %i[commits pull_request release].each { |type| return type if params.key?(type) }
  end

  private

  def validate_params
    render_error :invalid_integration_name if params[:integration_name] != 'git'
    render_error :invalid_payload if payload_type.nil?
  end

  def permitted_params
    case payload_type
    when :commits
      push_params
    when :pull_request
      pull_request_params
    when :release
      release_params
    end
  end

  def pull_request_params
    params.permit(:action, :number,
                  pull_request: [
                    :id, :number, :state, :title, :body, :created_at, :updated_at,
                    :closed_at, :merge_commit_sha, head: %i[sha],
                    user: ALLOWED_PARAMETERS[:user], commits: [ALLOWED_PARAMETERS[:commit]]
                  ], repository:   ALLOWED_PARAMETERS[:repository])
  end

  def push_params
    params.permit(:pushed_at, commits: [ALLOWED_PARAMETERS[:commit]], repository: ALLOWED_PARAMETERS[:repository],
                  pusher: ALLOWED_PARAMETERS[:user])
  end

  def release_params
    params.permit(:action, :released_at,
                  release:    [
                    :id, :tag_name, author: ALLOWED_PARAMETERS[:user], commits: [ALLOWED_PARAMETERS[:commit]]
                  ], repository: ALLOWED_PARAMETERS[:repository])
  end
end
