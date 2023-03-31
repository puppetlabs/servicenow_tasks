require 'spec_helper'
require_relative '../../tasks/write_common.rb'
require 'yaml'

describe 'servicenow_tasks::write_common' do
  let(:write_common) { WriteCommon.new } 
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
  let(:args) do
    {
      data: {'foo':3}
    }
  end
  context 'running write common task' do
    it 'errors when file not found' do
      allow(YAML).to receive(:load_file).with('/etc/puppetlabs/code/environments/production/hiera.yaml').and_return(hiera_file_no_datadir)
      allow(File).to receive(:file?).and_return(false)
      expect{write_common.task(args)}.to raise_error(TaskHelper::Error)
    end

    it 'appends to existing yaml data' do
      allow(YAML).to receive(:load_file).with('/etc/puppetlabs/code/environments/production/hiera.yaml').and_return(hiera_file_no_datadir)
      allow(YAML).to receive(:load_file).with('/etc/puppetlabs/code/environments/production/data/common.yaml').and_return(existing_common)
      allow(File).to receive(:open).with('/etc/puppetlabs/code/environments/production/data/common.yaml', "w")
      allow(File).to receive(:file?).and_return(true)
      expect(write_common.task(args)).to eq(
        {
          'test':1,
          'foo':3
        }
      )
    end

    it 'appends to empty common file' do
      allow(YAML).to receive(:load_file).with('/etc/puppetlabs/code/environments/production/hiera.yaml').and_return(hiera_file_no_datadir)
      allow(YAML).to receive(:load_file).with('/etc/puppetlabs/code/environments/production/data/common.yaml').and_return(blank_common)
      allow(File).to receive(:open).with('/etc/puppetlabs/code/environments/production/data/common.yaml', "w")
      allow(File).to receive(:file?).and_return(true)
      expect(write_common.task(args)).to eq(
        {
          'foo':3
        }
      )
    end

    it 'identifies proper datadir in hiera.yaml' do
      allow(YAML).to receive(:load_file).with('/etc/puppetlabs/code/environments/production/hiera.yaml').and_return(hiera_file_with_datadir)
      allow(YAML).to receive(:load_file).with('/etc/puppetlabs/code/environments/production/datadir/common.yaml').and_return(blank_common)
      allow(File).to receive(:open).with('/etc/puppetlabs/code/environments/production/datadir/common.yaml', "w")
      allow(File).to receive(:file?).and_return(true)
      expect(write_common.task(args)).to eq(
        {
          'foo':3
        }
      )
    end

    it 'uses the non-default hiera path when given as a parameter' do
      args[:hiera_yaml_path] = '/foo/bar/baz'
      allow(YAML).to receive(:load_file).with('/foo/bar/baz/hiera.yaml').and_return(hiera_file_with_datadir)
      allow(YAML).to receive(:load_file).with('/foo/bar/baz/datadir/common.yaml').and_return(blank_common)
      allow(File).to receive(:open).with('/foo/bar/baz/datadir/common.yaml', "w")
      allow(File).to receive(:file?).and_return(true)
      expect(write_common.task(args)).to eq(
        {
          'foo':3
        }
      )
    end
  end
end
