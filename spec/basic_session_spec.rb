# encoding: utf-8
require "spec_helper"

describe "performing a request" do
  before do
    Jiralicious.configure do |config|
      config.uri = "http://jstewart:topsecret@localhost"
    end

    stub_request(:get, "http://localhost/ok").to_return(status: 200)
  end

  let(:session) { Jiralicious::BasicSession.new }

  it "sets the basic auth info beforehand" do
    expect(Jiralicious::BasicSession).to receive(:basic_auth).with("jstewart", "topsecret")
    session.request(:get, "/ok")
  end
end
