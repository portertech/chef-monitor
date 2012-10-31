describe "monitor::server" do
  it "runs as a daemon" do
    service("sensu-server").must_be_running
  end
end
