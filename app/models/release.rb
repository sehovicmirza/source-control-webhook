# frozen_string_literal: true

class Release < ApplicationRecord
  belongs_to :user
  belongs_to :repository
  has_many   :commits
  has_many   :tickets

  before_destroy { commits.clear }

  validates :tag_name, presence: true, uniqueness: { scope: :repository_id }
end
