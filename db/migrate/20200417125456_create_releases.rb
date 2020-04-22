# frozen_string_literal: true

class CreateReleases < ActiveRecord::Migration[6.0]
  def change
    create_table :releases do |t|
      t.references :user, null: false, foreign_key: true
      t.references :repository, null: false, foreign_key: true

      t.string :action
      t.datetime :released_at
      t.string :tag_name

      t.timestamps
    end
  end
end
