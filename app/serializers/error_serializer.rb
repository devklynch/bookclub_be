class ErrorSerializer
  def self.format_errors(messages)
    {
      errors: messages.map { |msg| { detail: msg } }
    }
  end
end