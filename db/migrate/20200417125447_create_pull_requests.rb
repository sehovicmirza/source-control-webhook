# frozen_string_literal: true

class CreatePullRequests < ActiveRecord::Migration[6.0]
  def change
    create_table :pull_requests do |t|
      t.references :user, null: false, foreign_key: true
      t.references :repository, null: false, foreign_key: true

      t.string :action
      t.integer :number
      t.string :state
      t.string :title
      t.string :body
      t.datetime :closed_at
      t.string :merge_commit_sha
      t.string :head_sha

      t.timestamps
    end
  end
end
