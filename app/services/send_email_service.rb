# This class implements functionality to send Email using Iterator API. In case of Exceptions, method call will return 500
class SendEmailService
  include Constants, Connection
  attr_accessor :user_email, :campaign_id

  def initialize(options)
    @campaign_id = options[:campaign_id]
    @user_email = options[:user_email]
  end

  def call
    body = {
      "campaignId": campaign_id.to_i,
      "recipientEmail": user_email,
    }
    response = connection(:post, ITERABLE_URL+ITERABLE_EMAIL_URL, body)
    response.code.to_i
  rescue => e
    p e
    500
  end
end
