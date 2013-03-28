override["sensu"]["use_embedded_ruby"] = true
override["sensu"]["use_unstable_repo"] = true
override["sensu"]["version"] = "0.9.12.beta.6-2"

default["monitor"]["master_address"] = nil

default["monitor"]["environment_aware_search"] = false
default["monitor"]["use_local_ipv4"] = false

default["monitor"]["sensu_plugin_version"] = "0.1.6"

default["monitor"]["additional_client_attributes"] = Mash.new

default["monitor"]["default_handlers"] = ["debug"]
default["monitor"]["metric_handlers"] = ["debug"]
