class EventsInIteratorService
  include Constants, Connection
  attr_accessor :user_email, :event_type

  def initialize(options)
    @user_email = options[:user_email]
    @event_type = options[:event_type]
  end

  def call
    body = {
      "email": user_email,
      "eventName": event_type
    }
    response = connection(:post, ITERABLE_URL+ITERABLE_EVENTS_URL, body)
    response.code.to_i
  rescue => e
    p e
    500
  end
end
