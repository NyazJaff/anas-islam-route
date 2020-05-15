Rails.application.routes.draw do
  resources :questions
  resources :posts
  namespace 'api' do
    namespace 'v1' do
      resources :anas_islam
    end
  end
end
