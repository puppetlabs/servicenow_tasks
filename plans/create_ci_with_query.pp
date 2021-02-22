plan servicenow_tasks::create_ci_with_query(
  String $node,
  String $snow_instance,
  String $snow_username = '',
  Sensitive[String] $snow_password = Sensitive(''),
  Sensitive[String] $snow_oauth_token = Sensitive('')
){

    $test_node = {'node' => $node}

  # Get results from PDB by running the fact_query plan
  $result_set = run_plan(servicenow_tasks::fact_query, $test_node)

  $default_args = { 'table'              => 'cmdb_ci_server',
                    'instance'           => $snow_instance,
                    'certname'           => $node,
                    'fact_query_results' => $result_set }

  # Create args hash based on type of authentication
  if empty($snow_oauth_token.unwrap) {
    $args = $default_args + { 'user'               => $snow_username,
                              'password'           => $snow_password.unwrap }
  } else {
    $args = $default_args + { 'oauth_token'        => $snow_oauth_token.unwrap }
  }
  #Create CI by running task
  run_task('servicenow_tasks::create_ci', [$node], $args)
}
