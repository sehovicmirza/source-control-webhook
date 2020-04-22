# frozen_string_literal: true

class User < ApplicationRecord
  has_many :commits
  has_many :pull_requests
  has_many :releases

  validates :email, presence: true, uniqueness: { scope: :name }
end
