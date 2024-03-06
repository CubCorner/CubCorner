# frozen_string_literal: true

FactoryBot.define do
  factory(:post_deletion_reason) do
    sequence(:reason) { |n| "reason_#{n}" }
    sequence(:prompt) { |n| "reason_#{n}" }
    sequence(:title) { |n| "reason_#{n}" }
  end
end
