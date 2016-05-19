class CircleCiWebhookPayload < CircleCiPayload

  def convert_content!(raw_content)
    json_content = JSON.parse(raw_content)
    Array.wrap(json_content['payload'])
  rescue => e
    handle_processing_exception e
  end

end
