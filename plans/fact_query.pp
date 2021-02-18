plan servicenow_tasks::fact_query(
  String $node
){
  # Get results from PDB
  #assign to variable and modify custom function to return the query instead of the results
  $query = servicenow_tasks::pdb_results($node)

  #Not sure how to return json from a plan, temp work around = custom function
  return servicenow_tasks::tuple_to_json(puppetdb_query($query))

}
