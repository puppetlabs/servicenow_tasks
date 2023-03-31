#!/opt/puppetlabs/puppet/bin/ruby

require_relative '../files/snow_task_helper.rb'
require 'yaml'
# This task reads common from a given path 
##TODO add search by hiera level
class WriteCommon < TaskHelper
  def task(

    hiera_yaml_path: "/etc/puppetlabs/code/environments/production",
    data: {},
    **_kwargs)
 
    hiera_yaml = YAML.load_file("#{hiera_yaml_path}/hiera.yaml")

    datadir = 'data'
    if defined? hiera_yaml[:defaults][:datadir]
      datadir = hiera_yaml[:defaults][:datadir]
    end
    filename = "#{hiera_yaml_path}/#{datadir}/common.yaml"
    if !File.file?(filename)
      debug "hiera_yaml_path: #{hiera_yaml_path}"
      debug "common.yaml filepath: #{filename}"
      raise TaskHelper::Error.new("Common File not Found",
        "write_common/file-not-found",
        "debug" => debug_statements)
    end
    common_data = YAML.load_file(filename)
    merged_data = common_data.merge(data)
    File.open(filename, "w") do |f|
      YAML.dump(merged_data, f) 
    end
    merged_data
  end
end

if $PROGRAM_NAME == __FILE__
  WriteCommon.run
end
