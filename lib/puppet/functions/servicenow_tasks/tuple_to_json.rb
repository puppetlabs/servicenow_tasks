require 'json'

Puppet::Functions.create_function(:'servicenow_tasks::tuple_to_json') do
  dispatch :tuple_to_json do
    required_param 'Tuple',  :data
  end

  def tuple_to_json(data)
    data.to_json
  end
end
