#!/opt/puppetlabs/puppet/bin/ruby

require 'yaml'
require_relative '../lib/service_now_request.rb'

if $PROGRAM_NAME == __FILE__
  puts '{"environment" : "yolo"}'
  # config = YAML.load_file('/etc/puppetlabs/puppet/snow_record.yaml')

  # snowinstance = config['snowinstance']
  # table = config['table']
  # sys_id = config['sys_id']

  # uri = "https://#{snowinstance}.service-now.com/api/now/table/#{table}/#{sys_id}"

  # request = ServiceNowRequest.new(uri, 'Get', nil, user, password)
  # request.print_response
end
