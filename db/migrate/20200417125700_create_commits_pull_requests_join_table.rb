# frozen_string_literal: true

class CreateCommitsPullRequestsJoinTable < ActiveRecord::Migration[6.0]
  def change
    create_join_table :commits, :pull_requests do |t|
      t.index %i[commit_id pull_request_id]
      t.index %i[pull_request_id commit_id]
    end
  end
end
