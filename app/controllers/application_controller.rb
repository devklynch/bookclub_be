class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  rescue_from ActiveRecord::RecordInvalid do |e|
    render json: ErrorSerializer.format_errors(e.record.errors.full_messages), status: :unprocessable_entity
  end

  rescue_from ActiveRecord::RecordNotFound do |e|
    render json: ErrorSerializer.format_errors([e.message]), status: :not_found
  end

  def render_error
    render json: ErrorSerializer.format_errors(["Invalid search request"]), status: :bad_request
  end

end
