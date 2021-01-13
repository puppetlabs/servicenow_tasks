# servicenow_tasks

Tasks for fetching, manipulating, and creating ServiceNow records

#### Table of Contents

1. [Description](#description)
2. [Setup - The basics of getting started with servicenow_tasks](#setup)
3. [Usage - Configuration options and additional functionality](#usage)

## Description

servicenow_tasks provides a series of tasks to interact with a ServiceNow Instance. The 5 main tasks included with this module:

* create_record - Create a ServiceNow record
* get_record    - Get a ServiceNow record(s)
* update_record - Update a ServiceNow record
* delete_record - Delete a ServiceNow record
* create_ci     - Create a ServiceNow Configuration Item from Puppet facts

These tasks have been tested with an Orlando developer instance.

## Setup

The [puppetlabs-ruby_task_helper](https://forge.puppet.com/puppetlabs/ruby_task_helper) module must be installed

Tasks can be executed via Bolt by supplying a basic inventory file. For example, if you're using Bolt 1.x, this would look something like:

```bash
nodes:
  - name: dev84270.service-now.com
    config:
      transport: remote
      remote:
        user: admin
        password: "XHxH2tmZ69*Vbh"
        oauth_token: vXpDyYklhkNxwQ5ktr7WmTinZwq4-g-RSXtCVA5Y6JDKWU8-OBC3GUHbQIcWZyp1z1dKHK4_3-O8NQTzkWVCJw
```

> Bolt 1.x inventory entry

If you're using Bolt 2.x, then this would look something like:

```bash
targets:
  - uri: dev84270.service-now.com
    config:
      transport: remote
      remote:
        user: admin
        password: "XHxH2tmZ69*Vbh"
        oauth_token: vXpDyYklhkNxwQ5ktr7WmTinZwq4-g-RSXtCVA5Y6JDKWU8-OBC3GUHbQIcWZyp1z1dKHK4_3-O8NQTzkWVCJw
```

> Bolt 2.x inventory entry

Tasks can also be executed via puppet by specifying `user`/`password` or `oauth_token`, and `instance` parameters. Credentials specified via parameters will take precedence over any in an inventory file.

OAuth authentication will be used over a user/password if an oauth token is provided in either the inventory file or passed as a parameter.

## Usage

### get_record

To get a record from the incident table with sys_id = `3Db9b91557db00101096dde37a48961976`

```bash
bolt task run --targets dev84270.service-now.com servicenow_tasks::get_record table=incident sys_id=3Db9b91557db00101096dde37a48961976
```

or without an inventory file,

```bash
bolt task run --targets dev84270.service-now.com servicenow_tasks::get_record user=my_username password=my_password instance=my_instance table=incident sys_id=3Db9b91557db00101096dde37a48961976
```

### create_ci

To create a new CI in ServiceNow you must provide the following parameters in addition to the inventory/authentication data described [above](##setup). The create_ci task will return the sys_id of the new CI in ServiceNow.
- `table` : ServiceNow table. Defaults to cmdb_ci_server.
- `certname` : The certname for the node for which the CIs are being created.
- `fact_query_results` : A PuppetDB fact query result set as a valid JSON string that will be used to create CIs in ServiceNow.
- `fact_map` :  set of facts in valid json to send to ServiceNow to populate the new CI. A default set will be used if none is provided.

```bash
bolt task run servicenow_tasks::create_ci 
--targets 'dev99218.service-now.com' 
certname=puppet-master 
fact_query_results="[{\"name\":\"fqdn\",\"value\":\"puppet-master.c.splunk-275519.internal\"},{\"name\":\"domain\",\"value\":\"c.splunk-275519.internal\"},{\"name\":\"is_virtual\",\"value\":true},{\"name\":\"macaddress\",\"value\":\"42:01:0a:8a:00:03\"},{\"name\":\"processors\",\"value\":{\"isa\":\"x86_64\",\"count\":2,\"models\":[\"Intel(R) Xeon(R) CPU @ 2.20GHz\",\"Intel(R) Xeon(R) CPU @ 2.20GHz\"],\"physicalcount\":1}},{\"name\":\"serialnumber\",\"value\":\"GoogleCloud-F48713898D3A1DF97AF4AFC761243E4C\"},{\"name\":\"memorysize_mb\",\"value\":7812.03515625},{\"name\":\"processorcount\",\"value\":2},{\"name\":\"operatingsystemrelease\",\"value\":\"8.1.1911\"},{\"name\":\"physicalprocessorcount\",\"value\":1}]"
fact_map="{\"fqdn\":\"fqdn\",\"domain\":\"dns_domain\",\"serialnumber\":\"serial_number\",\"operatingsystemrelease\":\"os_version\",\"physicalprocessorcount\":\"cpu_count\",\"processorcount\":\"cpu_core_count\",\"processors.models.0\":\"cpu_type\",\"memorysize_mb\":\"ram\",\"is_virtual\":\"virtual\",\"macaddress\":\"mac_address\"}"
```
Further example usage is provided via `bolt task show`
