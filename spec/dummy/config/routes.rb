# frozen_string_literal: true

Rails.application.routes.draw do
  root to: "home#index"

  resource :playground, only: %i[show create]
end
