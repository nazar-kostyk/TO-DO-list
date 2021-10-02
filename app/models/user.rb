# frozen_string_literal: true

# == Schema Information
#
# Table name: users
#
#  id              :uuid             not null, primary key
#  email           :string           not null
#  name            :string(255)      not null
#  password_digest :string           not null
#  surname         :string(255)      not null
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#
# Indexes
#
#  index_users_on_email  (email) UNIQUE
#
class User < ApplicationRecord
  NAME_MAX_LENGTH = 255
  SURNAME_MAX_LENGTH = 255
  EMAIL_MIN_LENGTH = 5
  EMAIL_MAX_LENGTH = 64
  PASSWORD_MIN_LENGTH = 8
  PASSWORD_MAX_LENGTH = 64

  has_secure_password
  has_many :to_do_lists, dependent: :destroy
end
