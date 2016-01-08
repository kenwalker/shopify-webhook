require 'rubygems'
require 'base64'
require 'openssl'
require 'sinatra'

# The Shopify app's shared secret, viewable from the Partner dashboard
SHARED_SECRET = 'my_shared_secret'

puts "STARTING WEBHOOK RECEIVER"

helpers do
  # Compare the computed HMAC digest based on the shared secret and the request contents
  # to the reported HMAC in the headers
  def verify_webhook(data, hmac_header)
    digest  = OpenSSL::Digest::Digest.new('sha256')
    calculated_hmac = Base64.encode64(OpenSSL::HMAC.digest(digest, SHARED_SECRET, data)).strip
    calculated_hmac == hmac_header
  end
end


# Respond to HTTP POST requests sent to this web service
post '/' do
  request.body.rewind
  data = request.body.read
  verified = verify_webhook(data, env["HTTP_X_SHOPIFY_HMAC_SHA256"])

  # Output 'true' or 'false'
  puts "Webhook verified: #{verified}"
end

