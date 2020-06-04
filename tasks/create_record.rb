#!/opt/puppetlabs/puppet/bin/ruby

require_relative '../../ruby_task_helper/files/task_helper.rb'
require_relative '../lib/service_now_request.rb'

# This task creates records
class ServiceNowCreate < TaskHelper
  def task(table: nil,
           fields: nil,
           user: nil,
           password: nil,
           instance: nil,
           oauth_token: nil,
           _target: nil,
           **_kwargs)

    # Use the inventory file credentials if no user, password, or instance is passed in via parameters.
    user = _target[:user] if user.nil?
    password = _target[:password] if password.nil?
    oauth_token = _target[:oauth_token] if oauth_token.nil?
    instance = _target[:name] if instance.nil?

    uri = "https://#{instance}/api/now/table/#{table}"

    request = ServiceNowRequest.new(uri, 'Post', fields, user, password, oauth_token)
    request.print_response
  end
end

if $PROGRAM_NAME == __FILE__
  ServiceNowCreate.run
end
