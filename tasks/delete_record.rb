#!/opt/puppetlabs/puppet/bin/ruby

require_relative '../../ruby_task_helper/files/task_helper.rb'
require_relative '../lib/service_now_request.rb'

# This task deletes a record from a given table with a given sys_id
class ServiceNowDelete < TaskHelper
  def task(table: nil,
           sys_id: nil,
           user: nil,
           password: nil,
           instance: nil,
           _target: nil,
           **_kwargs)

    # Use the inventory file credentials if no user, password, or instance is passed in via parameters.
    user = _target[:user] if user.nil?
    password = _target[:password] if password.nil?
    instance = _target[:name] if instance.nil?

    uri = "https://#{instance}.service-now.com/api/now/table/#{table}/#{sys_id}"

    request = ServiceNowRequest.new(uri, 'Delete', nil, user, password)
    request.print_response
  end
end

if $PROGRAM_NAME == __FILE__
  ServiceNowDelete.run
end
