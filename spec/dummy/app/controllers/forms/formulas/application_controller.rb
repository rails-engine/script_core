# frozen_string_literal: true

module Forms
  class Formulas::ApplicationController < ApplicationController
    before_action :set_form
    before_action :set_formula

    protected

      # Use callbacks to share common setup or constraints between actions.
      def set_form
        @form = Form.find(params[:form_id])
      end

      def set_formula
        @formula = @form.formulas.find(params[:formula_id])
      end
  end
end
