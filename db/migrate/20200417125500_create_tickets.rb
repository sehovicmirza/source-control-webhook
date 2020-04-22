# frozen_string_literal: true

class CreateTickets < ActiveRecord::Migration[6.0]
  def change
    create_table :tickets do |t|
      t.references :release, foreign_key: true

      t.string :external_identifier
      t.string :state
      t.string :comment

      t.timestamps
    end
  end
end
