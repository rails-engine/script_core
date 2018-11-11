# frozen_string_literal: true

class Forms::FormulasController < Forms::ApplicationController
  before_action :set_formula, only: %i[show edit update destroy]

  # GET /forms/1/formulas
  def index
    @formulas = @form.formulas.all
  end

  # GET /forms/formulas/new
  def new
    @formula = @form.formulas.build
  end

  # GET /forms/1/formulas/1/edit
  def edit; end

  # POST /forms/1/formulas
  def create
    @formula = @form.formulas.build(formula_params)

    if @formula.save
      redirect_to form_formulas_url(@form), notice: "formula was successfully created."
    else
      render :new
    end
  end

  # PATCH/PUT /forms/1/formulas/1
  def update
    if @formula.update(formula_params)
      redirect_to form_formulas_url(@form), notice: "formula was successfully updated."
    else
      render :edit
    end
  end

  # DELETE /forms/1/formulas/1
  def destroy
    @formula.destroy
    redirect_to form_formulas_url(@form), notice: "formula was successfully destroyed."
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_formula
    @formula = @form.formulas.find(params[:id])
  end

  # Only allow a trusted parameter "white list" through.
  def formula_params
    params.fetch(:formula, {}).permit(:name, :body)
  end
end
