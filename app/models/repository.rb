# frozen_string_literal: true

class Repository < ApplicationRecord
  ALLOWED_NAMES = %w[ember_app suitepad_api suite_apk].freeze

  has_many :releases
  has_many :pull_requests
  has_many :commits, dependent: :destroy

  validates :name, presence: true, inclusion: { in: ALLOWED_NAMES }
end
