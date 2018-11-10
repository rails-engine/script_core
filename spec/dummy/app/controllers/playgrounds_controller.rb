# frozen_string_literal: true

class PlaygroundsController < ApplicationController
  before_action :set_source

  def show

  end

  def create
    @result = ScriptEngine.eval @source
  end

  private

  def set_source
    @source = params.fetch(:source, "")
  end
end
