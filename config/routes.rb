Rails.application.routes.draw do

  root 'questions#index'
  resources :questions
  namespace 'api' do
    namespace 'v1' do
      get "anas_islam/empty"                       => "anas_islam#empty"
      get "anas_islam/deleted"                     => "anas_islam#deleted"
      get "anas_islam/fatawa"                      => "anas_islam#fatawa"
      get "anas_islam/wakeup_server"               => "anas_islam#wakeup_server"
      # get "anas_islam/get_answered_questions"      => "anas_islam#get_answered_questions"
      get "anas_islam/format_current_question"     => "anas_islam#format_current_question"
      get "anas_islam/get_by_device_id/:device_id" => "anas_islam#get_by_device_id"

      resources :anas_islam
    end
  end
end
