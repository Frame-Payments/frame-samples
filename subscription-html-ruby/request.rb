require "net/http"
require "openssl"

module Request
  DEFAULT_TIMEOUT = 30

  ["get", "post"].each do |http_method|
    define_method("#{http_method}_request") do |path, options = {}|
      make_request(http_method, path, options)
    end
  end

  def make_request(verb, path, body)
    uri = URI("#{ENV["FRAME_API_URL"]}/v1" + path)
    request_class = Net::HTTP.const_get(verb.capitalize)
    request = request_class.new(uri.path, headers)
    request["Authorization"] = "Bearer #{ENV["FRAME_SECRET_KEY"]}"
    request["Content-Type"] = "application/json"

    if ["post", "put"].include?(verb.downcase)
      request.body = body.to_json
    end

    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE
    http.open_timeout = DEFAULT_TIMEOUT
    http.read_timeout = DEFAULT_TIMEOUT
    http.request(request)
  end
end
