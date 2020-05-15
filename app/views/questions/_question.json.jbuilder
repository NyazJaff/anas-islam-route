json.extract! question, :id, :question, :answer, :date_created_time, :phone_detail, :created_at, :updated_at
json.url question_url(question, format: :json)
