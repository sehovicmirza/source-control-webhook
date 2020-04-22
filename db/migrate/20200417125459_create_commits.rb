# frozen_string_literal: true

class CreateCommits < ActiveRecord::Migration[6.0]
  def change
    create_table :commits do |t|
      t.references :user, null: false, foreign_key: true
      t.references :repository, null: false, foreign_key: true
      t.references :release, foreign_key: true

      t.string :sha, null: false
      t.string :message, null: false
      t.datetime :date, null: false

      t.timestamps
    end
  end
end
