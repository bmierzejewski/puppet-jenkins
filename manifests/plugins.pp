class jenkins::plugins (
  $plugin_hash = {},
	$defaults = {}
) {
  validate_hash($plugin_hash)
  create_resources('jenkins::plugin', $plugin_hash, $defaults)
}
