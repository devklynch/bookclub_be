#!/usr/bin/env ruby

# Debug script for password reset flow
require_relative 'config/environment'

puts "=== Password Reset Debug Script ==="

# Find a user to test with
user = User.first
if user.nil?
  puts "No users found in database"
  exit
end

puts "Testing with user: #{user.email}"

# Check current reset token state
puts "Current reset token: #{user.reset_password_token}"
puts "Current reset password sent at: #{user.reset_password_sent_at}"
puts "Reset period valid: #{user.reset_password_period_valid?}"

# Generate a new reset token
puts "\nGenerating new reset token..."
user.send_reset_password_instructions

# Reload user to get updated token
user.reload

puts "New reset token: #{user.reset_password_token}"
puts "New reset password sent at: #{user.reset_password_sent_at}"
puts "Reset period valid: #{user.reset_password_period_valid?}"

# Test token validation
if user.reset_password_token.present?
  puts "\nTesting token validation..."
  
  # Test finding user by token
  found_user = User.find_by(reset_password_token: user.reset_password_token)
  puts "User found by token: #{found_user&.email}"
  
  # Test period validation
  puts "Period valid: #{found_user&.reset_password_period_valid?}"
  
  # Test token expiration (6 hours from sent time)
  if found_user&.reset_password_sent_at
    expiration_time = found_user.reset_password_sent_at + 6.hours
    puts "Token expires at: #{expiration_time}"
    puts "Current time: #{Time.current}"
    puts "Token expired: #{Time.current > expiration_time}"
  end
else
  puts "No reset token generated!"
end

puts "\n=== Debug Complete ==="
