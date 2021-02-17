#!/opt/puppetlabs/puppet/bin/ruby

require_relative '../../ruby_task_helper/files/task_helper.rb'
require_relative '../lib/service_now.rb'

class ServiceNowGetToken < TaskHelper
  def task(
    instance: nil,
    user: nil,
    password: nil,
    client_id: nil,
    client_secret: nil,
    _target: nil,
    **_kwargs
  )
  
  client = ServiceNow.new(instance, user: user, password: password, client_id: client_id, client_secret: client_secret)
  client.oauth_token
  end
end

if $PROGRAM_NAME == __FILE__
  ServiceNowGetToken.run
end
