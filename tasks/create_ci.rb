#!/opt/puppetlabs/puppet/bin/ruby

require_relative '../../ruby_task_helper/files/task_helper.rb'
require_relative '../lib/service_now.rb'

# This task creates a CI record in Servicenow based on a PuppetDB query
class ServiceNowCreateCI < TaskHelper
  def task(table: 'cmdb_ci_server',
    user: nil,
    password: nil,
    instance: nil,
    oauth_token: nil,
    certname: nil,
    fact_query_results: nil,
    fact_map: JSON({# PuppetDB fact => ServiceNow CI field
                    'fqdn'                   => 'fqdn',
                    'domain'                 => 'dns_domain',
                    'serialnumber'           => 'serial_number',
                    'operatingsystemrelease' => 'os_version',
                    'physicalprocessorcount' => 'cpu_count',
                    'processorcount'         => 'cpu_core_count',
                    'processors.models.0'    => 'cpu_type',
                    'memorysize_mb'          => 'ram',
                    'is_virtual'             => 'virtual',
                    'macaddress'             => 'mac_address'}),
    _target: nil,
    **_kwargs)

    # Example of a result fact set from PuppetDB
    # fact_query_results_json = "[{\"name\":\"fqdn\",\"value\":\"puppet-master.c.splunk-275519.internal\"},{\"name\":\"domain\",\"value\":\"c.splunk-275519.internal\"},{\"name\":\"is_virtual\",\"value\":true},{\"name\":\"macaddress\",\"value\":\"42:01:0a:8a:00:03\"},{\"name\":\"processors\",\"value\":{\"isa\":\"x86_64\",\"count\":2,\"models\":[\"Intel(R) Xeon(R) CPU @ 2.20GHz\",\"Intel(R) Xeon(R) CPU @ 2.20GHz\"],\"physicalcount\":1}},{\"name\":\"serialnumber\",\"value\":\"GoogleCloud-F48713898D3A1DF97AF4AFC761243E4C\"},{\"name\":\"memorysize_mb\",\"value\":7812.03515625},{\"name\":\"processorcount\",\"value\":2},{\"name\":\"operatingsystemrelease\",\"value\":\"8.1.1911\"},{\"name\":\"physicalprocessorcount\",\"value\":1}]"

    # Convert JSON parameters to ruby data structures
    begin
      fact_query_results = JSON.parse(fact_query_results)
    rescue JSON::ParserError => e
      raise "Invalid fact_query_results json: #{e}"
    end

    begin
      fact_map = JSON.parse(fact_map)
    rescue JSON::ParserError => e
      raise "Invalid fact_map json: #{e}"
    end

    # Use the inventory file credentials if no user, password, or instance is passed in via parameters.
    if _target
      user = _target[:user] if user.nil?
      password = _target[:password] if password.nil?
      oauth_token = _target[:oauth_token] if oauth_token.nil?
      instance = _target[:name] if instance.nil?
    end

    # This check is neccesary because all of these are optional params because they can be supplied through parameters or an inventory file.
    unless (instance && user && password) || (instance && oauth_token)
      raise "Please supply a ServiceNow instance, user, and password, or instance and oauth_token."
    end

    # Convert the output to a more useable single hash (PDB returns an array of hashes)
    facts = fact_query_results.map { |item| [item['name'], item['value']] }.to_h

    # Build the payload for ServiceNow, set the mandatory 'name' field to the node's certname.
    fact_payload = { 'name' => certname }

    # Add facts based on the fact_map at the start of the function
    fact_map.each do |fact, ci_field|
      if fact.split('.').count > 1
        # Dot-walk structured facts
        tmp_fact = facts
        fact.split('.').each do |sub_fact|
          tmp_fact = ((sub_fact.to_i.to_s == sub_fact) ? tmp_fact[sub_fact.to_i] : tmp_fact[sub_fact])
        end
        fact_payload[ci_field] = tmp_fact.to_s
      else
        # Directly use non-structured facts
        fact_payload[ci_field] = facts[fact].to_s
      end
    end

    client = ServiceNow.new(instance, user: user, password: password, oauth_token: oauth_token)
    # Return the ServiceNow sys_id for the cmdb_ci entry we just created.
    client.create_table_record(table, fact_payload.to_json)['result']['sys_id']
  end
end

if $PROGRAM_NAME == __FILE__
  ServiceNowCreateCI.run
end
