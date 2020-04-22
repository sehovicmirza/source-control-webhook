# frozen_string_literal: true

FactoryBot.define do
  factory :ticket do
    external_identifier { '#foo-123' }
    state { 'ready for release' }
  end
end
