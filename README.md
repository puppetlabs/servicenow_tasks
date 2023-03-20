# servicenow_tasks

Tasks for fetching, manipulating, and creating ServiceNow records

#### Table of Contents

1. [Description](#description)
2. [Setup - The basics of getting started with servicenow_tasks](#setup)
3. [Usage - Configuration options and additional functionality](#usage)

## Description

servicenow_tasks provides a series of tasks to interact with a ServiceNow Instance. The 5 main tasks included with this module:

* create_record - Create a ServiceNow record
* get_record    - Get a ServiceNow record
* get_records   - Get ServiceNow records
* update_record - Update a ServiceNow record
* delete_record - Delete a ServiceNow record
* create_ci     - Create a ServiceNow Configuration Item from Puppet facts
* get_token     - Get a ServiceNow oauth token

There are two additional plans:
* fact_query - Returns PDB query results in JSON
* create_ci_with_query - Create a ServiceNow Configuration Item from a PDB query


These tasks/plans have been tested with an Orlando and Paris developer instance.

## Setup

The [puppetlabs-ruby_task_helper](https://forge.puppet.com/puppetlabs/ruby_task_helper) module must be installed

Tasks can be executed via Bolt by supplying a basic inventory file. For example this would look something like:


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

### Tasks
### get_record

This task gets a record from ServiceNow. Provide the following parameters in addition to the inventory/authentication data described [above](##setup).

Required parameters:
- `table` : ServiceNow table.
- `sys_id` : sys_id of the record you want.

```bash
bolt task run --targets dev84270.service-now.com servicenow_tasks::get_record table=incident sys_id=3Db9b91557db00101096dde37a48961976
```

or without an inventory file,

```bash
bolt task run --targets dev84270.service-now.com servicenow_tasks::get_record user=my_username password=my_password instance=my_instance table=incident sys_id=3Db9b91557db00101096dde37a48961976
```

```bash
puppet task run servicenow_tasks::get_record \
sys_id='1asdf' \
table='incident' \
user='admin' password='74rByafftSFQVCYf' instance='dev106575.service-now.com' \
--nodes sauterne-victim.delivery.puppetlabs.net
```

### get_records
This task gets multiple records from ServiceNow. Provide the following parameters in addition to the inventory/authentication data described [above](##setup).

Required Parameters:
- `table` : ServiceNow table.

```bash
puppet task run servicenow_tasks::get_records \
table='incident' \
user='admin' password='74rByafftSFQVCYf' instance='dev106575.service-now.com' \
--nodes sauterne-victim.delivery.puppetlabs.net
```

### create_ci

This task creates a new CI in ServiceNow. Provide the following parameters in addition to the inventory/authentication data described [above](##setup). The create_ci task will return the sys_id of the new CI in ServiceNow.

Required Parameters:
- `table` : ServiceNow table. Defaults to cmdb_ci_server.
- `certname` : The certname for the node for which the CIs are being created.
- `fact_query_results` : A PuppetDB fact query result set as a valid JSON string that will be used to create CIs in ServiceNow.
- `fact_map` :  set of facts in valid json to send to ServiceNow to populate the new CI. A default set will be used if none is provided.

```bash
bolt task run servicenow_tasks::create_ci
certname=puppet-master
fact_query_results="[{\"name\":\"fqdn\",\"value\":\"puppet-master.c.splunk-275519.internal\"},{\"name\":\"domain\",\"value\":\"c.splunk-275519.internal\"},{\"name\":\"is_virtual\",\"value\":true},{\"name\":\"macaddress\",\"value\":\"42:01:0a:8a:00:03\"},{\"name\":\"processors\",\"value\":{\"isa\":\"x86_64\",\"count\":2,\"models\":[\"Intel(R) Xeon(R) CPU @ 2.20GHz\",\"Intel(R) Xeon(R) CPU @ 2.20GHz\"],\"physicalcount\":1}},{\"name\":\"serialnumber\",\"value\":\"GoogleCloud-F48713898D3A1DF97AF4AFC761243E4C\"},{\"name\":\"memorysize_mb\",\"value\":7812.03515625},{\"name\":\"processorcount\",\"value\":2},{\"name\":\"operatingsystemrelease\",\"value\":\"8.1.1911\"},{\"name\":\"physicalprocessorcount\",\"value\":1}]"
fact_map="{\"fqdn\":\"fqdn\",\"domain\":\"dns_domain\",\"serialnumber\":\"serial_number\",\"operatingsystemrelease\":\"os_version\",\"physicalprocessorcount\":\"cpu_count\",\"processorcount\":\"cpu_core_count\",\"processors.models.0\":\"cpu_type\",\"memorysize_mb\":\"ram\",\"is_virtual\":\"virtual\",\"macaddress\":\"mac_address\"}"
--targets 'dev99218.service-now.com'
```
Further example usage is provided via `bolt task show`

```bash
puppet task run servicenow_tasks::create_ci \
certname='sauterne-victim.delivery.puppetlabs.net' \
user='admin' password='74rByafftSFQVCYf' instance='dev106575.service-now.com' \
fact_query_results="[{\"name\":\"fqdn\",\"value\":\"puppet-master.c.splunk-275519.internal\"},{\"name\":\"domain\",\"value\":\"c.splunk-275519.internal\"},{\"name\":\"is_virtual\",\"value\":true},{\"name\":\"macaddress\",\"value\":\"42:01:0a:8a:00:03\"},{\"name\":\"processors\",\"value\":{\"isa\":\"x86_64\",\"count\":2,\"models\":[\"Intel(R) Xeon(R) CPU @ 2.20GHz\",\"Intel(R) Xeon(R) CPU @ 2.20GHz\"],\"physicalcount\":1}},{\"name\":\"serialnumber\",\"value\":\"GoogleCloud-F48713898D3A1DF97AF4AFC761243E4C\"},{\"name\":\"memorysize_mb\",\"value\":7812.03515625},{\"name\":\"processorcount\",\"value\":2},{\"name\":\"operatingsystemrelease\",\"value\":\"8.1.1911\"},{\"name\":\"physicalprocessorcount\",\"value\":1}]" \
--nodes sauterne-victim.delivery.puppetlabs.net
```
To use oauth_token, replace user and password parameters with oauth_token as shown in create_ci.

### create_record
This task creates a new record in ServiceNow. You must provide the following parameters in addition to the inventory/authentication data described [above](##setup). The create_record task will return the sys_id of the new record in ServiceNow.

Required Parameters:
- `table` : ServiceNow table.
- `fields` : The ServiceNow fields. This is a JSON hash.

```bash
puppet task run servicenow_tasks::create_record \
table='incident' \
fields="{}" \
user='admin' password='74rByafftSFQVCYf' instance='dev106575.service-now.com' \
--nodes sauterne-victim.delivery.puppetlabs.net
```

### get_token
This task returns an oauth token of the ServiceNow instance. Provide the following parameters in addition to the inventory/authentication data described [above](##setup).

Required Paramters:
- `client_id` : The client_id of the oauth API endpoint.
- `client_secret` : The client_secret of the oauth API endpoint.

```bash
puppet task run servicenow_tasks::get_token \
user='admin' password='74rByafftSFQVCYf' instance='dev106575.service-now.com' \
client_id='41a8f4b72e122010b05d1676ab5be5c4' \
client_secret='test' \
--nodes sauterne-victim.delivery.puppetlabs.net
```

### delete_record
This task deletes a record in a specified table in ServiceNow. Provide the following parameters in addition to the inventory/authentication data described [above](##setup).

Required Parameters:
- `table` : ServiceNow table.
- `sys_id` : sys_id of the record you want.

```bash
puppet task run servicenow_tasks::delete_record \
user='admin' password='74rByafftSFQVCYf' instance='dev106575.service-now.com' \
table='incident' \
sys_id='99f4fd732f922010593e578b2799b6a1' \
--nodes sauterne-victim.delivery.puppetlabs.net
```

### update_record
This task updates a specified record. Provide the following parameters in addition to the inventory/authentication data described [above](##setup).

Required Parameters:
- `table` : ServiceNow table.
- `sys_id` : sys_id of the record you want.
- `fields` : The ServiceNow fields. This is a JSON hash.

```bash
puppet task run servicenow_tasks::update_record \
table='incident' \
sys_id='3asdf' \
fields="{}" \
user='admin' password='74rByafftSFQVCYf' instance='dev106575.service-now.com' \
--nodes sauterne-victim.delivery.puppetlabs.net
```

### Plans
### fact_query

This plan calls the custom function pdb_results to run the query and returns the PDB query results in JSON.

```bash
puppet plan run servicenow_tasks::fact_query node=sadder-parsley.delivery.puppetlabs.net
```


### create_ci_with_query

Given a node(certname), this plan will query for a default set of facts, and then use this set of facts to create CIs in ServiceNow. It utilizes the create_ci task to do this. As with the tasks, if an oauth token is provided, it will be used, otherwise username and password will be used. It returns the sys_id of the CI created.

```bash
puppet plan run servicenow_tasks::create_ci_with_query node=sadder-parsley.delivery.puppetlabs.net snow_instance=dev99218.service-now.com snow_username=admin snow_password=fancypassword
```
