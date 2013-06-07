#!/usr/bin/env bats

@test "should have a graphite handler definition" {
  [ -e "/etc/sensu/conf.d/handlers/graphite.json" ]
}
