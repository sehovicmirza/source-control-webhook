# frozen_string_literal: true

class PullRequest < ApplicationRecord
  ALLOWED_STATES =  %w[closed created approved].freeze

  belongs_to :user
  belongs_to :repository
  has_and_belongs_to_many :commits

  validates :state, presence: true, inclusion: { in: ALLOWED_STATES }
  validates :number, presence: true, uniqueness: { scope: :repository_id }
  validates :merge_commit_sha, presence: true, uniqueness: { scope: :repository_id }
end
