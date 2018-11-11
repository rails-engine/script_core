# frozen_string_literal: true

class Formula < ApplicationRecord
  belongs_to :form

  validates :name,
            presence: true
end
