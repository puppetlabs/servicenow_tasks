#!/opt/puppetlabs/puppet/bin/ruby

require_relative '../../ruby_task_helper/files/task_helper.rb'
require_relative '../lib/service_now_request.rb'

# This task deletes a record from a given table with a given sys_id
class ServiceNowDelete < TaskHelper
  def task(table: nil,
           sys_id: nil,
           _target: nil,
           **_kwargs)

    user = _target[:user]
    password = _target[:password]
    instance = _target[:name]

    uri = "https://#{instance}.service-now.com/api/now/table/#{table}/#{sys_id}"

    request = ServiceNowRequest.new(uri, 'Delete', nil, user, password)
    request.print_response
  end
end

if $PROGRAM_NAME == __FILE__
  ServiceNowDelete.run
end
