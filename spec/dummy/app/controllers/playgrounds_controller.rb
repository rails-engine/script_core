# frozen_string_literal: true

class PlaygroundsController < ApplicationController
  before_action :set_source

  def show
    @source = <<~CODE
      puts "You can use `puts` to output strings to (fake) stdout for logging..."
      puts "Call multiple absolutely OK!"

      str = ""
      (1..3).each do |i|
        str += "Hello world!!! x\#{i}; "
      end

      set_output str
    CODE
  end

  def create
    @result = ScriptEngine.eval @source
  end

  private

  def set_source
    @source = params.fetch(:source, "")
  end
end
