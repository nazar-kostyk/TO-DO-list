# frozen_string_literal: true

module Users
  class CreateParamsValidator < BaseValidator
    params do
      required(:name).filled(:string)
      required(:surname).filled(:string)
      required(:email).filled(:string)
      required(:password).filled(:string)
      required(:password_confirmation).filled(:string)
    end

    register_macro(:email_uniqueness) do
      key.failure(:not_unique, field: :email) if !rule_error?(:email) && User.exists?(email: value)
    end

    register_macro(:passwords_match) do
      key.failure(:passwords_do_not_match) if value != values[:password]
    end

    rule(:name).validate(max_length: User::NAME_MAX_LENGTH)

    rule(:surname).validate(max_length: User::SURNAME_MAX_LENGTH)

    rule(:email).validate(min_length: User::EMAIL_MIN_LENGTH)
    rule(:email).validate(max_length: User::EMAIL_MAX_LENGTH)
    rule(:email).validate(:email_format)
    rule(:email).validate(:email_uniqueness)

    rule(:password).validate(min_length: User::PASSWORD_MIN_LENGTH)
    rule(:password).validate(max_length: User::PASSWORD_MAX_LENGTH)

    rule(:password_confirmation).validate(:passwords_match)
  end
end
