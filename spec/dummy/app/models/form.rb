# frozen_string_literal: true

class Form < MetalForm
  has_many :formulas, dependent: :delete_all

  validates :title,
            presence: true
end
