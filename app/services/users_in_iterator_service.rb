# This class implements functionality to save Users in Iterator. In case of Exceptions, method call will return 500
class UsersInIteratorService
  include Constants, Connection
  attr_accessor :user_id, :user_email

  def initialize(options)
    @user_id = options[:user_id]
    @user_email = options[:user_email]
  end

  def call
    body = {
      "email": user_email,
      "userId": user_id
    }
    response = connection(:post, ITERABLE_URL+ITERABLE_USERS_URL, body)
    response.code.to_i
  rescue => e
    p e
    500
  end
end
