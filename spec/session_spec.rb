# encoding: utf-8
require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

module ConfiguationHelper
  def self.included(base)
    Jiralicious.configure do |config|
      config.username = "jstewart"
      config.password = "topsecret"
      config.uri = "http://localhost"
      config.api_version = "latest"
    end
  end
end

describe Jiralicious::Session, "logging in" do
  include ConfiguationHelper

  context "successfully" do
    before :each do
      response = %Q|
      {
        "session": {
        "name": "JSESSIONID",
        "value": "12345678901234567890"
      },
        "loginInfo": {
          "failedLoginCount": 10,
          "loginCount": 127,
          "lastFailedLoginTime": "2011-07-25T06:31:07.556-0500",
          "previousLoginTime": "2011-07-25T06:31:07.556-0500"
        }
      }
      |
      FakeWeb.register_uri(:post,
                           Jiralicious.uri + '/rest/auth/latest/session',
                           :body => response)
      @session = Jiralicious::Session.new
      @session.login
    end

    it "is alive" do
      @session.should be_alive
    end

    it "populates the session and login info" do
      @session.session.should == {
        "name" =>  "JSESSIONID",
        "value" => "12345678901234567890"
      }
      @session.login_info.should == {
        "failedLoginCount" =>  10,
        "loginCount" =>  127,
        "lastFailedLoginTime" => "2011-07-25T06:31:07.556-0500",
        "previousLoginTime" => "2011-07-25T06:31:07.556-0500"
      }
    end
  end

  context "with an invalid login" do
    before :each do
      FakeWeb.register_uri(:post,
                           Jiralicious.uri + '/rest/auth/latest/session',
                           :status => ["401", "Not Authorized"])
      @session = Jiralicious::Session.new
    end

    it "raises the correct exception" do
      lambda { @session.login }.
        should raise_error(Jiralicious::InvalidLogin)
    end

    it "is not alive" do
      begin; @session.login; rescue Jiralicious::InvalidLogin; end
      @session.should_not be_alive
    end

    it "clears the session and login info" do
      @session.login_info = "GARBAGE"
      @session.session = "GARBAGE"
      begin; @session.login; rescue Jiralicious::InvalidLogin; end
      @session.login_info.should be_nil
      @session.session.should be_nil
    end
  end

  context "when CAPTCHA is required" do
    before :each do
      FakeWeb.register_uri(:post,
                           Jiralicious.uri + '/rest/auth/latest/session',
                           :status => ["403", "Captcha Required"])
      @session = Jiralicious::Session.new
    end

    it "raises an exception" do
      lambda { @session.login }.
        should raise_error(Jiralicious::CaptchaRequired)
    end

    it "clears the session and login info" do
      @session.login_info = "GARBAGE"
      @session.session = "GARBAGE"
      begin; @session.login; rescue Jiralicious::CaptchaRequired; end
      @session.login_info.should be_nil
      @session.session.should be_nil
    end
  end

  context "with any other HTTP error" do
    before :each do
      FakeWeb.register_uri(:post,
                           Jiralicious.uri + '/rest/auth/latest/session',
                           :status => ["500", "Internal Server Error"])
      @session = Jiralicious::Session.new
    end

    it "raises an exception" do
      lambda { @session.login }.
        should raise_error(Jiralicious::JiraError)
    end

    it "clears the session and login info" do
      @session.login_info = "GARBAGE"
      @session.session = "GARBAGE"
      begin; @session.login; rescue Jiralicious::JiraError; end
      @session.login_info.should be_nil
      @session.session.should be_nil
    end

    it "gives the Net::HTTP reason for failure" do
      begin
        @session.login
      rescue Jiralicious::JiraError => e
        e.message.should == "Internal Server Error"
      end
    end
  end
end

describe Jiralicious::Session, "logging out" do
  include ConfiguationHelper
  before :each do
    @session = Jiralicious::Session.new
    @session.login
    @session.should be_alive
    @session.logout
  end

  it "is not alive"
  it "clears the session and login info"
end