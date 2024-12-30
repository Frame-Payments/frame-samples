require "sinatra"
require 'dotenv'
require "net/http"
require "openssl"

Dotenv.load

set :static, true
set :public_folder, File.join(File.dirname(__FILE__), "./client/html")
set :port, 4242
set :bind, "0.0.0.0"

get "/" do
  content_type "text/html"
  send_file File.join(settings.public_folder, "index.html")
end

get '/config' do
  content_type 'application/json'

  { publishableKey: ENV['FRAME_PUBLISHABLE_KEY'] }.to_json
end

# An endpoint to start the payment process
post "/create-charge-intent" do
  content_type 'application/json'
  data = JSON.parse(request.body.read)

  charge_intent_body = {
    amount: 200, # $2.00
    customer: ENV["CUSTOMER_ID"], # The ID of the customer to charge
    currency: "usd",
    confirm: true,
    payment_method_data: {
      card_number: data["payment_method"]["number"],
      cvc: data["payment_method"]["cvc"],
      exp_month: data["payment_method"]["expiry"]["month"],
      exp_year: data["payment_method"]["expiry"]["year"],
      type: "card",
      billing: { # optional but we recommend providing it
        line_1: "180 Private 7785 Rd E #7785 E",
        city: "Broaddus",
        country: "US",
        state: "TX",
        postal_code: "75929"
      }
    }
  }

  url = URI("#{ENV["FRAME_API_URL"]}/v1/charge_intents")
  http = Net::HTTP.new(url.host, url.port)
  http.use_ssl = true
  http.verify_mode = OpenSSL::SSL::VERIFY_NONE
  request = Net::HTTP::Post.new(url)
  request["Authorization"] = "Bearer #{ENV["FRAME_SECRET_KEY"]}"
  request["Content-Type"] = 'application/json'
  request.body = charge_intent_body.to_json
  response = http.request(request)
  response_body = JSON.parse(response.read_body)

  { clientSecret: response_body["client_secret"] }.to_json
end
