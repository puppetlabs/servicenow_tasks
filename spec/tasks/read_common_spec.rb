require 'spec_helper'
require_relative '../../tasks/read_common.rb'
require 'yaml'

describe 'servicenow_tasks::read_common' do
  let(:read_common) { ReadCommon.new } 
  let(:hiera_file_no_datadir) { 
    {
      "version": 5,
      "defaults": nil,
      "hierarchy": [
        {
          "name": "Per-node data (yaml version)",
          "path": "nodes/%{::trusted.certname}.yaml"
        },
        {
          "name": "Other YAML hierarchy levels",
          "paths": [
            "common.yaml"
          ]
        }
      ]
    } 
  }
  let(:hiera_file_with_datadir) { 
    {
      "version": 5,
      "defaults": {
        "datadir": "datadir"
      },
      "hierarchy": [
        {
          "name": "Per-node data (yaml version)",
          "path": "nodes/%{::trusted.certname}.yaml"
        },
        {
          "name": "Other YAML hierarchy levels",
          "paths": [
            "common.yaml"
          ]
        }
      ]
    }
  }
  let(:blank_common) { {} }
  let(:existing_common) { {"test": 1} }
  let(:args) { {} }
  context 'running read common task' do
    it 'errors when file not found' do
      allow(YAML).to receive(:load_file).with('/etc/puppetlabs/code/environments/production/hiera.yaml').and_return(hiera_file_no_datadir)
      allow(File).to receive(:file?).and_return(false)
      expect{read_common.task(args)}.to raise_error(TaskHelper::Error)
    end

    it 'reads existing yaml data' do
      allow(YAML).to receive(:load_file).with('/etc/puppetlabs/code/environments/production/hiera.yaml').and_return(hiera_file_no_datadir)
      allow(YAML).to receive(:load_file).with('/etc/puppetlabs/code/environments/production/data/common.yaml').and_return(existing_common)
      allow(File).to receive(:file?).and_return(true)
      expect(read_common.task(args)).to eq(
        {
          'test':1
        }
      )
    end

    it 'creates empty common file when create_new is true' do
      args[:create_new] = true

      allow(YAML).to receive(:load_file).with('/etc/puppetlabs/code/environments/production/hiera.yaml').and_return(hiera_file_no_datadir)
      allow(YAML).to receive(:load_file).with('/etc/puppetlabs/code/environments/production/data/common.yaml').and_return(blank_common)
      expect(File).to receive(:open).with('/etc/puppetlabs/code/environments/production/data/common.yaml', "w")
      allow(File).to receive(:file?).and_return(false)
      expect(read_common.task(args)).to eq( {} )
    end

    it 'identifies proper datadir in hiera.yaml' do
      allow(YAML).to receive(:load_file).with('/etc/puppetlabs/code/environments/production/hiera.yaml').and_return(hiera_file_with_datadir)
      allow(YAML).to receive(:load_file).with('/etc/puppetlabs/code/environments/production/datadir/common.yaml').and_return(existing_common)
      allow(File).to receive(:file?).and_return(true)
      expect(read_common.task(args)).to eq(
        {
          'test':1
        }
      )
    end

    it 'uses the non-default hiera path when given as a parameter' do
      args[:hiera_yaml_path] = '/foo/bar/baz'
      allow(YAML).to receive(:load_file).with('/foo/bar/baz/hiera.yaml').and_return(hiera_file_with_datadir)
      allow(YAML).to receive(:load_file).with('/foo/bar/baz/datadir/common.yaml').and_return(existing_common)
      allow(File).to receive(:file?).and_return(true)
      expect(read_common.task(args)).to eq(
        {
          'test':1
        }
      )
    end
  end
end
