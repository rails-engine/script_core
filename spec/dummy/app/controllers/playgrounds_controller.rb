# frozen_string_literal: true

class PlaygroundsController < ApplicationController
  before_action :set_source

  def show
    @source = <<~CODE
      puts "You can use `puts` to output strings to (fake) stdout for logging."
      puts "Call multiple absolutely OK!"

      module Foo
        class Bar
          attr_reader :flag

          def initialize(val)
            @flag = val
          end
        end
      end

      var = Foo::Bar.new(false) # try to set `true`
      if var.flag
        return "No time to say Hello."
      end

      str = ""
      (1..3).each do |i|
        str += "Hello world!!! x\#{i}; "
      end

      str # In dummy the last line is the return value
    CODE
  end

  def create
    @result = ScriptEngine.run_inline @source
  end

  private

    def set_source
      @source = params.fetch(:source, "")
    end
end
