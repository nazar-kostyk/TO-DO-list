# frozen_string_literal: true

module ToDoLists
  class CreateToDoList < BaseService
    attr_reader :user, :params

    def initialize(user, params)
      @user = user
      @params = params
    end

    def call
      return validation_errors if validator.failure?

      to_do_list = ToDoList.new(model_params)

      to_do_list.save ? build_success_response(to_do_list) : build_database_error_response
    end

    private

    def validator
      @validator ||= ::ToDoLists::CreateParamsValidator.new.call(params)
    end

    def validation_errors
      build_validation_errors_response(validator.errors.to_h)
    end

    def model_params
      params.merge({ user_id: user.id }).compact_blank
    end
  end
end
