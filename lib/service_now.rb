require 'base64'
require 'json'
require 'net/http'
require 'openssl'

# This class organizes ruby http code used by all of the tasks.
class ServiceNow
  attr_reader :oauth_token

  # oauth_token is used for auth if provided.
  def initialize(instance, user: nil, password: nil, oauth_token: nil, client_id: nil, client_secret: nil, use_ssl: true)
    #instance example: https://dev99218.service-now.com
    instance_with_protocol = use_ssl ? "https://localhost" : "http://localhost"
    @instance = URI.parse(instance_with_protocol)
    @user = user
    @password = password
    if (client_id && client_secret && user && password)
      @oauth_token = get_token(client_id, client_secret)
    else
      @oauth_token = oauth_token
    end
  end

  def valid_json?(value)
    result = JSON.parse(value)
    result.is_a?(Hash) || result.is_a?(Array)
  rescue JSON::ParserError, TypeError
    false
  end

  def get_token(client_id, client_secret)
    body = "grant_type=password"\
           "&client_id=#{client_id}"\
           "&client_secret=#{client_secret}"\
           "&username=#{@user}"\
           "&password=#{@password}"
    make_request("/oauth_token.do", 'POST', body: body, return_hash: true, get_token: true)['access_token']
  end

  def create_table_record(table, body)
    raise "Create table record expects JSON for the body" unless valid_json?(body)
    endpoint = "/api/now/table/#{table}"
    make_request(endpoint, 'POST', body: body, return_hash:true)
  end

  def delete_table_record(table, sys_id)
    endpoint = "/api/now/table/#{table}/#{sys_id}"
    make_request(endpoint, 'DELETE')
  end

  def get_table_record(table, sys_id)
    endpoint = "/api/now/table/#{table}/#{sys_id}"
    make_request(endpoint, 'GET')
  end

  def get_table_records(table, url_params)
    endpoint = "/api/now/table/#{table}"
    make_request(endpoint, 'GET', query: url_params)
  end

  def update_table_record(table, body, sys_id)
    raise "Create table record expects JSON for the body" unless valid_json?(body)
    endpoint = "/api/now/table/#{table}/#{sys_id}"
    make_request(endpoint, 'PATCH', body: body)
  end

  def make_request(endpoint, http_verb, query: nil, body: nil, return_hash: false, get_token: false)
    Net::HTTP.start(@instance.host,
                    #@instance.port,
                    8000,
                    use_ssl: @instance.scheme == 'https',
                    verify_mode: OpenSSL::SSL::VERIFY_NONE) do |http|
      # For fetching a token from ServiceNow, it wants a string body, not json
      if get_token
        header = {}
      else
        header = { 'Content-Type' => 'application/json' }
      end
      # Interpolate the HTTP verb and constantize to a class name.
      request_class_string = "Net::HTTP::#{http_verb.capitalize}"
      request_class = Object.const_get(request_class_string)
      # Add uri, fields and authentication to request
      endpt_with_query = query ? "#{endpoint}?#{query}" : endpoint
      request = request_class.new(endpt_with_query, header)
      request.body = body if body
      unless get_token
        if @oauth_token
          request['Authorization'] = "Bearer #{@oauth_token}"
        else
          request.basic_auth(@user, @password)
        end
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
