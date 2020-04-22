# frozen_string_literal: true

class CreateCommitsTicketsJoinTable < ActiveRecord::Migration[6.0]
  def change
    create_join_table :commits, :tickets do |t|
      t.index %i[commit_id ticket_id]
      t.index %i[ticket_id commit_id]
    end
  end
end
