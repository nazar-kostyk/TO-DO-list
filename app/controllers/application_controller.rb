# frozen_string_literal: true

# ApplicationController: base controller
class ApplicationController < ActionController::API
  def authorize_request
    header = request.headers['Authorization']
    header = header.split.last if header

    begin
      decoded = JsonWebToken.decode(header)
      @current_user = User.find(decoded[:user_id])
    rescue ActiveRecord::RecordNotFound
      render_json_error(status: :not_found, error_key: 'user_not_found')
    rescue JWT::DecodeError
      render_json_error(status: :unauthorized, error_key: 'unauthorized_request')
    end
  end

  def render_json_error(status:, error_key:)
    code = Rack::Utils::SYMBOL_TO_STATUS_CODE[status] if status.is_a? Symbol

    error = {
      code: code,
      title: I18n.t("error_messages.#{error_key}.title", default: ''),
      detail: I18n.t("error_messages.#{error_key}.detail", default: '')
    }.compact_blank

    render json: { errors: [error] }, status: status
  end

  def render_json_validation_error(errors_hash)
    errors =
      errors_hash.map do |attribute_name, error_details|
        error_details.map do |detail|
          {
            source: {
              pointer: "/data/attributes/#{attribute_name}"
            },
            detail: detail
          }
        end
      end.flatten

    render json: { errors: errors }, status: :bad_request
  end
end
