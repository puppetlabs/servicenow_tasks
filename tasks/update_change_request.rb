#!/opt/puppetlabs/puppet/bin/ruby

require 'base64'
require 'json'

require 'net/http'
require 'openssl'

require_relative '../../ruby_task_helper/files/task_helper.rb'

# This task updates objects
class SnowUpdateChangeRequest < TaskHelper
  def task(type: 'emergency',
           sys_id: nil,
           data: nil,
           _target: nil,
           **_kwargs)
    user = _target[:user]
    password = _target[:password]
    instance = _target[:name]

    uri = URI.parse("https://#{instance}.service-now.com/api/sn_chg_rest/change/#{type}/#{sys_id}?description=Reboot my email server")

    begin
      Net::HTTP.start(uri.host, uri.port,
                      use_ssl: uri.scheme == 'https',
                      verify_mode: OpenSSL::SSL::VERIFY_NONE) do |http|
        header = { 'Content-Type' => 'application/json', 'Accept' => 'application/json'}
        request = Net::HTTP::Patch.new("#{uri.path}?#{uri.query}", header)
        request.body = data
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
      raise TaskHelper::Error.new('Failure!', 'snow_record.snow_update_change_request', e)
    end
  end
end

if $PROGRAM_NAME == __FILE__
  SnowUpdateChangeRequest.run
end
