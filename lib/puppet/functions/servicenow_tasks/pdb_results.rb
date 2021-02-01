require 'json'

Puppet::Functions.create_function(:'servicenow_tasks::pdb_results') do
  dispatch :pdb_results do
    required_param 'String',  :node
  end

  def pdb_results(node)
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

   fact_query_filter = []
   fact_map.each do |fact, _field|
     fact_name = fact.split('.')[0]
     fact_query_filter.push("name='#{fact_name}'")
   end
   
   "facts[name,value] { (#{fact_query_filter.join(' or ')}) and certname = '#{node}' }"
  end
end
