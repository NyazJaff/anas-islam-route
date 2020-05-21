Rails.application.routes.draw do

  root 'questions#index'
  # resources :questions
  namespace 'api' do
    namespace 'v1' do
      get "anas_islam/get_by_device_id/:device_id" => "anas_islam#get_by_device_id"
      get "anas_islam/get_answered_questions" => "anas_islam#get_answered_questions"
      get "anas_islam/wakeup_server" => "anas_islam#wakeup_server"
      resources :anas_islam
    end
  end
end
