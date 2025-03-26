class ErrorSerializer
  def self.format_errors(messages)
    {
      errors: messages.map { |msg| { message: msg } }
    }
  end
end