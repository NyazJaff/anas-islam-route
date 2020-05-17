Rails.application.routes.draw do

  root 'questions#index'
  resources :questions
  resources :posts
  namespace 'api' do
    namespace 'v1' do
      resources :anas_islam do
        get :add_to_firebase
      end
    end
  end
end
