class UserSerializer
  include JSONAPI::Serializer
  
  attributes :email, :display_name
end