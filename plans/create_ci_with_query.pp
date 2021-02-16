plan servicenow_tasks::create_ci_with_query(
  String $node,
  String $snow_instance,
  String $snow_username = '',
  Sensitive[String] $snow_password = Sensitive(''),
  Sensitive[String] $snow_oauth_token = Sensitive('')
){

  # Get results from PDB
  $result_set = servicenow_tasks::pdb_results($node)

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
  run_task('servicenow_tasks::create_ci', [$node], $args)
}