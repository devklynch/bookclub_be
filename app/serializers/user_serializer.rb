class UserSerializer
  include JSONAPI::Serializer
  
  attributes :email, :display_name, :created_at, :updated_at
  
  # Add a computed attribute for the user's full profile
  attribute :profile_complete do |user|
    user.display_name.present? && user.email.present?
  end
end