#!/usr/bin/env bats

@test "should have a haproxy services check definition" {
  [ -e "/etc/sensu/conf.d/checks/haproxy_services.json" ]
}

@test "should have a haproxy plugin" {
  [ -e "/etc/sensu/plugins/check-haproxy.rb" ]
}

@test "should have a sudoers file for sensu" {
  [ -e "/etc/sudoers.d/sensu" ]
}

@test "should have a haproxy stats socket" {
  [ -e "/var/run/haproxy.sock" ]
}
