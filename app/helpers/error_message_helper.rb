module ErrorMessageHelper
  def error_messages_for model
    if model.errors.present?
      error_messages = model.errors.full_messages

      render partial: 'shared/error_messages', locals: {
        error_messages: error_messages,
        error_count: error_messages.length,
        model_name: model.class.model_name.human.downcase
      }
    end
  end
end
