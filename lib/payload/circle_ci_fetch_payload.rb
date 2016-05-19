class CircleCiFetchPayload < CircleCiPayload

  def convert_content!(raw_content)
    convert_json_content!(raw_content)
  end

end
