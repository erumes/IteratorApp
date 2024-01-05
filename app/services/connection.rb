# Connection module to have a common connection method for all request types
module Connection
  include Constants

  def connection(method, url, body=nil)
    uri = URI(url)
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    case method
    when :get
      request = get_req(uri)
    when :post
      request = post_req(uri)
      request.body = body.to_json
    end
    request["Content-Type"] = "application/json"
    request["Api-Key"] = Rails.application.credentials.iterator_api_key
    http.request(request)
  end

  def post_req(uri)
    Net::HTTP::Post.new(uri.request_uri)
  end

  def get_req(uri)
    Net::HTTP::Get.new(uri.request_uri)
  end
end
