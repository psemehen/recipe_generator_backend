require "active_record"

module JsonResponse
  extend ActiveSupport::Concern

  included do
    rescue_from ActiveRecord::RecordNotFound, with: :not_found
    rescue_from ActiveRecord::RecordInvalid, with: :unprocessable_entity
    rescue_from ArgumentError, with: :handle_argument_error
    rescue_from ActiveModel::ValidationError, with: :handle_validation_error
  end

  def json_response(object, status = :ok)
    render json: object, status: status
  end

  def json_error(message, status = :unprocessable_entity)
    render json: {errors: {message: message}}, status: status
  end

  private

  def not_found(exception)
    json_error(exception.message, :not_found)
  end

  def unprocessable_entity(exception)
    json_error(exception.record.errors.full_messages.join(", "), :unprocessable_entity)
  end

  def handle_argument_error(exception)
    json_error("Invalid argument: #{exception.message}", :bad_request)
  end

  def handle_validation_error(exception)
    json_error(exception.model.errors.full_messages.join(", "), :unprocessable_entity)
  end
end
