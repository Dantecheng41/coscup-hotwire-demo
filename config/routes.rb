Rails.application.routes.draw do
  root "articles#index"

  resources :articles

  get 'frames_demo', to: 'articles#frames_demo'
end
