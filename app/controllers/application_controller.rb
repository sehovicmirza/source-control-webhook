# frozen_string_literal: true

class ApplicationController < ActionController::API
  protected

  def render_error(error_code)
    error_object = build_error_object(error_code)
    render json: { error: error_object }, status: error_object[:status]
  end

  private

  def build_error_object(error_code)
    {}.tap do |error|
      %i[status code title].each do |field|
        error[field] = I18n.t(field, scope: "errors.#{error_code}", default: nil)
      end
    end
  end
end
