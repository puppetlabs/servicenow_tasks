#!/opt/puppetlabs/puppet/bin/ruby

require 'cgi'
require_relative '../../ruby_task_helper/files/task_helper.rb'
require_relative '../lib/service_now.rb'

# This task creates records
class ServiceNowGetRecords < TaskHelper
  def task(table: nil,
           url_params: nil,
           user: nil,
           password: nil,
           instance: nil,
           oauth_token: nil,
           _target: nil,
           **_kwargs)

    # Use the inventory file credentials if no user, password, or instance is passed in via parameters.
    if _target
      user = _target[:user] if user.nil?
      password = _target[:password] if password.nil?
      oauth_token = _target[:oauth_token] if oauth_token.nil?
      instance = _target[:name] if instance.nil?
    end

    url_params ||= {}
    url_params = url_params.map do |name, value|
      "#{CGI.escape(name.to_s)}=#{CGI.escape(value.to_s)}"
    end
    url_params = url_params.join('&')

    client = ServiceNow.new(instance, user: user, password: password, oauth_token: oauth_token)
    client.get_table_records(table, url_params)
    end
end

if $PROGRAM_NAME == __FILE__
  ServiceNowGetRecords.run
end
