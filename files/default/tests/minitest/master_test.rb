require File.expand_path('../support/helpers', __FILE__)

describe "monitor::master" do
  include Helpers::Monitor

  it "runs the sensu server" do
    service("sensu-server").must_be_running
  end
end
