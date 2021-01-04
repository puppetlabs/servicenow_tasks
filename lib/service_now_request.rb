require_relative '../../ruby_task_helper/files/task_helper.rb'
require 'base64'
require 'json'
require 'net/http'
require 'openssl'

# This class organizes ruby http code used by all of the tasks.
class ServiceNowRequest
  # oauth_token is used for auth if provided.
  def initialize(uri, http_verb, body, user = nil, password = nil, oauth_token = nil)
    @uri = URI.parse(uri)
    @http_verb = http_verb.capitalize
    @body = body.to_json
    @user = user
    @password = password
    @oauth_token = oauth_token
  end

  def print_response(return_hash: false)
    Net::HTTP.start(@uri.host,
                    @uri.port,
                    use_ssl: @uri.scheme == 'https',
                    verify_mode: OpenSSL::SSL::VERIFY_NONE) do |http|
      header = { 'Content-Type' => 'application/json' }
      # Interpolate the HTTP verb and constantize to a class name.
      request_class_string = "Net::HTTP::#{@http_verb}"
      request_class = Object.const_get(request_class_string)
      # Add uri, fields and authentication to request
      request = request_class.new("#{@uri.path}?#{@uri.query}", header)
      request.body = @body
      if @oauth_token
        request['Authorization'] = "Bearer #{@oauth_token}"
      else
        request.basic_auth(@user, @password)
      end
      # Make request to ServiceNow
      response = http.request(request)
      if response.body && !response.body.empty?
        # Parse and print response
        hash_response = JSON.parse(response.body)
        return hash_response if return_hash
        pretty_response = JSON.pretty_unparse(hash_response)
        puts [pretty_response]
      end
    end
  rescue => e
    raise "Request failed, #{e}"
  end
end
