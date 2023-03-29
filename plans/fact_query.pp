plan servicenow_tasks::fact_query(
  String $node
) {
  # Get results from PDB
  $query = servicenow_tasks::pdb_results($node)

  #Return PDB query results in JSON
  return servicenow_tasks::tuple_to_json(puppetdb_query($query))
}
