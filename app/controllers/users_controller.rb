# frozen_string_literal: true

class UsersController < ApplicationController
  before_action :authorize_request, except: :create

  def show
    render_json_response(user: @current_user, status: :ok)
  end

  def create
    validator = Users::Create::CreateParamsValidator.new.call(permitted_create_params)

    if validator.success?
      @user = User.new(permitted_create_params.slice(:name, :surname, :email, :password))
      if @user.save
        render_json_response(user: @user, status: :created)
      else
        render_json_error(status: :unprocessable_entity, error_key: 'database_error')
      end
    else
      render_json_validation_error(validator.errors.to_h)
    end
  end

  def update
    validator = Users::Update::UpdateParamsValidator.new.call(permitted_update_params)

    if validator.success?
      return render_json_error(status: :unauthorized, error_key: 'wrong_password') unless correct_password_provdided?

      if @current_user.update(map_request_params_to_model_params)
        render_json_response(user: @current_user, status: :ok)
      else
        render_json_error(status: :unprocessable_entity, error_key: 'database_error')
      end
    else
      render_json_validation_error(validator.errors.to_h)
    end
  end

  private

  def permitted_create_params
    params.permit(:name, :surname, :email, :password, :password_confirmation).to_h
  end

  def permitted_update_params
    params.permit(:name, :surname, :email, :current_password, :new_password, :new_password_confirmation).to_h
  end

  def correct_password_provdided?
    @current_user.authenticate(permitted_update_params[:current_password])
  end

  def map_request_params_to_model_params
    request_params = permitted_update_params

    request_params.slice(:name, :surname, :email)
                  .merge({ password: request_params[:new_password] })
                  .compact
  end

  def render_json_response(user:, status: :ok)
    render json: UserSerializer.new(user).serializable_hash, status: status
  end
end