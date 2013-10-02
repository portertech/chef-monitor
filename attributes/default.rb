override["sensu"]["use_embedded_ruby"] = true

default["monitor"]["master_address"] = nil

default["monitor"]["environment_aware_search"] = false
default["monitor"]["use_local_ipv4"] = false

default["monitor"]["sensu_plugin_version"] = "0.2.1"

default["monitor"]["additional_client_attributes"] = Mash.new

default["monitor"]["sudo_commands"] = Array.new

default["monitor"]["default_handlers"] = ["debug"]
default["monitor"]["metric_handlers"] = ["debug"]
