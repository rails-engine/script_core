# frozen_string_literal: true

module Forms
  class Formulas::PlaygroundsController < Forms::Formulas::ApplicationController
    before_action :set_virtual_model

    def show
      @form_record = @virtual_model.new
    end

    def create
      @form_record = @virtual_model.new form_record_params
      return render :show unless @form_record.valid?

      @payload = @form_record.serializable_hash
      @result = ScriptEngine.run_inline @formula.body, payload: @payload
    end

    private

      def set_virtual_model
        @virtual_model = @form.to_virtual_model
      end

      def form_record_params
        params.fetch(:form_record, {}).permit!
      end
  end
end
