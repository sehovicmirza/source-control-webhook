# frozen_string_literal: true

class Commit < ApplicationRecord
  MESSAGE_FORMAT = /\A(FIX: |CHORE: |FEAT: ).+(Ref: )(#[a-z]+-[1-9]+, )*(#[a-z]+-[1-9]+)\z/m.freeze

  belongs_to :user
  belongs_to :repository
  belongs_to :release, optional: true
  has_and_belongs_to_many :tickets
  has_and_belongs_to_many :pull_requests

  validates :message, presence: true, format: MESSAGE_FORMAT
  validates :sha, presence: true, uniqueness: { scope: :repository_id }
end
