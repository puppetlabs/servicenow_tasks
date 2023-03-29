#!/opt/puppetlabs/puppet/bin/ruby

require_relative '../../ruby_task_helper/files/task_helper.rb'
require 'yaml'

# This task reads common from a given path 
##TODO add search by hiera level
class ReadCommon < TaskHelper
  def task(

    hiera_yaml_path: "/etc/puppetlabs/code/environments/production/",
    create_new: false,
    **_kwargs)
 
    hiera_yaml = YAML.load_file("#{hiera_yaml_path}/hiera.yaml")

    datadir = 'data'
    if defined? hiera_yaml["defaults"]["datadir"]
      datadir = hiera_yaml["defaults"]["datadir"]
    end
    filename = "#{hiera_yaml_path}/#{datadir}/common.yaml"
    if !File.file?(filename)
      if !create_new
        debug "hiera_yaml_path: #{hiera_yaml_path}"
        debug "create_new: #{create_new}"
        debug "common.yaml filepath: #{filename}"
        raise TaskHelper::Error.new("Common File not Found",
          "read_common/file-not-found",
          "debug" => debug_statements)
      else
        File.open(filename, "w") do |f|
          f.write("---  {}\n")   
        end
      end
    end

    common_data = YAML.load_file(filename)
  end
end

if $PROGRAM_NAME == __FILE__
  ReadCommon.run
end
