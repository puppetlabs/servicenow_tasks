# servicenow_tasks

Tasks for manipulating ServiceNow records

#### Table of Contents

1. [Description](#description)
2. [Setup - The basics of getting started with servicenow_tasks](#setup)
3. [Usage - Configuration options and additional functionality](#usage)

## Description

servicenow_tasks provides a series of tasks to interact with a ServiceNow Instance. The 4 main tasks included with this module:

* create_record - Create a ServiceNow record
* get_record - Get a ServiceNow record(s)
* update_record - Update a ServiceNow record
* delete_record - Delete a ServiceNow record

These tasks have been tested with an Orlando developer instance.

## Setup

The [puppetlabs-ruby_task_helper](https://forge.puppet.com/puppetlabs/ruby_task_helper) module must be installed

Tasks can be executed via bolt by supplying a basic inventory file:

* `name` ServiceNow Instance [name]..service-now.com
* `config` of which:
  * `transport` Always `remote`
* remote:
  * user: ServiceNow Username
  * password: ServiceNow Password  

For example:

```bash
nodes:
  - name: dev85564
    config:
      transport: remote
      remote:
        user: admin
        password: "XHxH2tmZ69*Vbh"
```

## Usage

To get a record from the incident table with sys_id = `3Db9b91557db00101096dde37a48961976`

```bash
bolt task run --nodes dev84270 servicenow_tasks::get_record table=incident sys_id=3Db9b91557db00101096dde37a48961976
```

Further example usage is provided via `bolt task show`
