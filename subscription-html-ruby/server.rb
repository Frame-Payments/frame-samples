require "sinatra"
require "dotenv"
require "net/http"
require "openssl"
require_relative "request"

Dotenv.load

include Request

set :static, true
set :public_folder, File.join(File.dirname(__FILE__), "./client/html")
set :port, 4242
set :bind, "0.0.0.0"

get "/" do
  content_type "text/html"
  send_file File.join(settings.public_folder, "index.html")
end

get '/js/:filename' do |filename|
  content_type 'application/javascript'
  send_file File.join(settings.root, '..', 'dist', filename)
end

get '/config' do
  content_type 'application/json'

  { publishableKey: ENV['FRAME_PUBLISHABLE_KEY'] }.to_json
end

post "/create-subscription" do
  content_type "application/json"
  data = JSON.parse(request.body.read)

  customer_id = data["customerId"]
  product_id = data["productId"]

  # create a payment method
  payment_method_params = {
    "type": "card",
    "card_number": data["payment_method"]["number"],
    "exp_month": data["payment_method"]["expiry"]["month"],
    "exp_year": data["payment_method"]["expiry"]["year"],
    "cvc": data["payment_method"]["cvc"],
    "customer": customer_id,
    "billing": {
      "line_1": "45 Winding Hill Rd",
      "city": "Halifax",
      "country": "US",
      "state": "PA",
      "postal_code": 17032
    }
  }
  payment_method_response = post_request("/payment_methods", payment_method_params)
  payment_method = JSON.parse(payment_method_response.read_body)

  # create a subscription
  subscription_params = {
    customer: customer_id,
    product: product_id,
    currency: "USD",
    default_payment_method: payment_method["id"]
  }
  subscription_response = post_request("/subscriptions", subscription_params)
  subscription = JSON.parse(subscription_response.read_body)

  # retrieve the charge intent of the subscription
  charge_intent_response = get_request("/charge_intents/#{subscription["latest_charge_intent"]}")
  charge_intent = JSON.parse(charge_intent_response.read_body)

  { clientSecret: charge_intent["client_secret"] }.to_json
end
