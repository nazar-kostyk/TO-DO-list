# frozen_string_literal: true

# == Schema Information
#
# Table name: tasks
#
#  id            :uuid             not null, primary key
#  is_completed  :boolean          default(FALSE)
#  position      :integer          not null
#  title         :string(255)      default("Untitled")
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  to_do_list_id :uuid             not null
#
# Indexes
#
#  index_tasks_on_to_do_list_id               (to_do_list_id)
#  index_tasks_on_to_do_list_id_and_position  (to_do_list_id,position) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (to_do_list_id => to_do_lists.id)
#
FactoryBot.define do
  factory :task do
    to_do_list
    title { Faker::Lorem.sentence }
    is_completed { Faker::Boolean.boolean }
    sequence(:position, 0)
  end
end
