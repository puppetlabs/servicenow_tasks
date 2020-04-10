#!/opt/puppetlabs/puppet/bin/ruby

require_relative '../../ruby_task_helper/files/task_helper.rb'
require '../lib/service_now_request.rb'

# This task creates records
class ServiceNowCreate < TaskHelper
  def task(table: nil,
           fields: nil,
           _target: nil,
           **_kwargs)

    user = _target[:user]
    password = _target[:password]
    instance = _target[:name]

    uri = "https://#{instance}.service-now.com/api/now/table/#{table}"

    request = ServiceNowRequest.new(uri, 'Post', fields, user, password)
    request.print_response
  end
end

if $PROGRAM_NAME == __FILE__
  ServiceNowCreate.run
end
