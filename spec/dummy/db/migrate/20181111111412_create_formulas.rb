# frozen_string_literal: true

class CreateFormulas < ActiveRecord::Migration[5.2]
  def change
    create_table :formulas do |t|
      t.string :name
      t.text :body
      t.references :form, foreign_key: true

      t.timestamps
    end
  end
end
