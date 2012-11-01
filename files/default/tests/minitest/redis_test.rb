require File.expand_path('../support/helpers', __FILE__)

describe "monitor::redis" do
  include Helpers::Monitor

  it "runs the sensu client" do
    service("sensu-client").must_be_running
  end
end
