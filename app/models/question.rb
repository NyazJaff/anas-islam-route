class Question
  include Mongoid::Document
  include Mongoid::Timestamps

  field :question, type: String
  field :answer, type: String
  field :phone_detail, type: String
  field :deleted, type: Boolean, default: false
  # field :answered, type: Boolean, default: false
end
