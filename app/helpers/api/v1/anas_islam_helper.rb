module Api::V1::AnasIslamHelper

  def to_bool(value)
    ActiveModel::Type::Boolean.new.cast value
  end

end
