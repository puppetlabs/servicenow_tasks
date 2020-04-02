#!/opt/puppetlabs/puppet/bin/ruby

require 'base64'
require 'json'

require 'net/http'
require 'openssl'

require_relative '../../ruby_task_helper/files/task_helper.rb'

# This task creates incidents
class SnowCreateStandardChangeRequest < TaskHelper
  def task(standard_change_template_id: nil,
           _target: nil,
           **_kwargs)
    user = _target[:user]
    password = _target[:password]
    instance = _target[:name]

    uri = URI.parse("https://#{instance}.service-now.com/api/sn_chg_rest/change/standard/#{standard_change_template_id}")

    begin
      Net::HTTP.start(uri.host, uri.port,
                      use_ssl: uri.scheme == 'https',
                      verify_mode: OpenSSL::SSL::VERIFY_NONE) do |http|
        header = { 'Content-Type' => 'application/json' }
        request = Net::HTTP::Post.new(uri.path, header)
        data = {}
        request.body = data.to_json
        request.basic_auth(user, password)
        response = http.request(request)
        datum = response.body
        obj = JSON.parse(datum)
        pretty_str = JSON.pretty_unparse(obj)
        res = [pretty_str]
        puts res
      end
    rescue => e
      puts "ERROR: #{e}"
      raise TaskHelper::Error.new('Failure!', 'snow_record.create_standard_change_request', e)
    end
  end
end

if $PROGRAM_NAME == __FILE__
  SnowCreateStandardChangeRequest.run
end
