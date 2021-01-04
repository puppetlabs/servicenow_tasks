#!/opt/puppetlabs/puppet/bin/ruby

require_relative '../../ruby_task_helper/files/task_helper.rb'
require_relative '../lib/service_now_request.rb'

# This task creates records
class ServiceNowCreateCI < TaskHelper
  def task(table: 'cmdb_ci_server',
           user: nil,
           password: nil,
           instance: nil,
           oauth_token: nil,
           node: 'puppet-master',
           _target: nil,
           **_kwargs)

    # Use the inventory file credentials if no user, password, or instance is passed in via parameters.
    user = _target[:user] if user.nil?
    password = _target[:password] if password.nil?
    oauth_token = _target[:oauth_token] if oauth_token.nil?
    instance = _target[:name] if instance.nil?

    # Map facts to populate when auto-creating CI's
    fact_map = {
      # PuppetDB fact => ServiceNow CI field
      'fqdn'                   => 'fqdn',
      'domain'                 => 'dns_domain',
      'serialnumber'           => 'serial_number',
      'operatingsystemrelease' => 'os_version',
      'physicalprocessorcount' => 'cpu_count',
      'processorcount'         => 'cpu_core_count',
      'processors.models.0'    => 'cpu_type',
      'memorysize_mb'          => 'ram',
      'is_virtual'             => 'virtual',
      'macaddress'             => 'mac_address',
    }

    # Build a PuppetDB query to get relevant facts
    fact_query_filter = []
    fact_map.each do |fact, _field|
      fact_name = fact.split('.')[0]
      fact_query_filter.push("name='#{fact_name}'")
    end

    query = "facts[name,value] { (#{fact_query_filter.join(' or ')}) and certname = '#{node}' }"

    # Instantiate Bolt's PDB client directly
    puppetdb_client = Puppet.lookup(:bolt_pdb_client)

    # Query PuppetDB
    fact_hash = puppetdb_client.make_query(query)

    # Convert the output to a more useable single hash (PDB returns an array of hashes)
    facts = fact_hash.map { |item| [item['name'], item['value']] }.to_h

    # Build the payload for ServiceNow, set the mandatory 'name' field to the node's certname
    fact_payload = { 'name' => node }

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

    uri = "https://#{instance}/api/now/table/#{table}"
    request = ServiceNowRequest.new(uri, 'Post', fact_payload, user, password, oauth_token)
    JSON.parse(request.body)['result']['sys_id']
  end
end

if $PROGRAM_NAME == __FILE__
  ServiceNowCreateCI.run
end
