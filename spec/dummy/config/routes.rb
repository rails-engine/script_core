# frozen_string_literal: true

Rails.application.routes.draw do
  root to: "home#index"

  resource :playground, only: %i[show create]

  resources :forms, except: %i[show] do
    scope module: :forms do
      resources :fields, except: %i[show]
      resources :formulas, except: %i[show] do
        scope module: :formulas do
          resource :playground, only: %i[show create]
        end
      end
    end
  end

  resources :fields, only: %i[] do
    scope module: :fields do
      resource :validations, only: %i[edit update]
      resource :options, only: %i[edit update]
      resources :choices, except: %i[show]
    end
  end

  resources :nested_forms, only: %i[] do
    scope module: :nested_forms do
      resources :fields, except: %i[show]
    end
  end

  resource :time_zone, only: [:update]
end
