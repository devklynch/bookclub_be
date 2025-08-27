class CustomDeviseMailer < Devise::Mailer
  helper :application # gives access to helpers defined within `application_helper`.
  include Devise::Controllers::UrlHelpers # gives access to `confirmation_url`, etc.
  default template_path: 'devise/mailer' # to make sure that your mailer uses the devise views

  def reset_password_instructions(record, token, opts={})
    # Override the default URL to point to your frontend
    @token = token
    @resource = record
    @reset_url = "#{Rails.application.config.x.frontend_url}/reset_password?reset_password_token=#{token}"
    
    Rails.logger.info "=== CustomDeviseMailer Debug ==="
    Rails.logger.info "Record ID: #{record.id}"
    Rails.logger.info "Record email: #{record.email}"
    Rails.logger.info "Token parameter received: #{token}"
    Rails.logger.info "Token parameter class: #{token.class}"
    Rails.logger.info "Token parameter length: #{token.to_s.length}"
    Rails.logger.info "Record reset_token in database: #{record.reset_password_token}"
    Rails.logger.info "Record reset_sent_at in database: #{record.reset_password_sent_at}"
    Rails.logger.info "Token assigned to @token: #{@token}"
    Rails.logger.info "Reset URL being generated: #{@reset_url}"
    Rails.logger.info "================================"
    
    # Create the email manually to ensure we control the token
    mail(
      to: record.email,
      subject: 'Reset password instructions',
      from: Rails.application.credentials.gmail[:username]
    ) do |format|
      format.html { render 'devise/mailer/reset_password_instructions' }
      format.text { render 'devise/mailer/reset_password_instructions' }
    end
  end
end
