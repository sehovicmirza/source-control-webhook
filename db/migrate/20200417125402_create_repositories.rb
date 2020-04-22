# frozen_string_literal: true

class CreateRepositories < ActiveRecord::Migration[6.0]
  def change
    create_table :repositories do |t|
      t.string :name

      t.timestamps
    end
  end
end
