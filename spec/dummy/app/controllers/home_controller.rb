# frozen_string_literal: true

class HomeController < ApplicationController
  def index
    redirect_to playground_url
  end
end
