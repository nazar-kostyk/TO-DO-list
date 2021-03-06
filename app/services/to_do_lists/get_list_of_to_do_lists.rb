# frozen_string_literal: true

module ToDoLists
  class GetListOfToDoLists < BaseService
    attr_reader :user

    def initialize(user)
      @user = user
    end

    def call
      to_do_lists = retrieve_to_do_lists

      build_success_response(to_do_lists)
    end

    private

    def retrieve_to_do_lists
      user.to_do_lists.includes(:tasks)
    end
  end
end
