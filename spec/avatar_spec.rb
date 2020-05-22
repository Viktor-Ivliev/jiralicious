# encoding: utf-8
require "spec_helper"

describe Jiralicious, "avatar" do
  before :each do
    Jiralicious.configure do |config|
      config.username = "jstewart"
      config.password = "topsecret"
      config.uri = "http://jstewart:topsecret@localhost"
      config.auth_type = :basic
      config.api_version = "latest"
    end

    rest_path = Jiralicious.rest_path.sub('jstewart:topsecret@', '')

    stub_request(
      :get, "#{rest_path}/avatar/user/system"
    ).to_return(status: 200, body: avatar_list_json)

    stub_request(
      :post, "#{rest_path}/avatar/user/temporary"
    ).to_return(status: 200, body: avatar_temp_json)

    stub_request(
      :post, "#{rest_path}/avatar/user/temporaryCrop"
    ).to_return(status: 200, body: avatar_temp_json)
  end

  it "obtain system avatar list" do
    avatar = Jiralicious::Avatar.system("user")
    expect(avatar).to be_instance_of(Jiralicious::Avatar)
    expect(avatar.system.count).to eq(2)
    expect(avatar.system[0].id).to eq("10100")
    expect(avatar.system[1].isSystemAvatar).to eq(true)
  end

  it "sends new avatar" do
    file = "#{File.dirname(__FILE__)}/fixtures/avatar_test.png"
    avatar = Jiralicious::Avatar.temporary("user", filename: file, size: 4035)
    expect(avatar.needsCropping).to eq(true)
  end

  it "crops the current avatar" do
    response = Jiralicious::Avatar.temporary_crop("user", cropperWidth: 120,
                                                          cropperOffsetX: 50,
                                                          cropperOffsety: 50,
                                                          needsCropping: false)
    expect(response.response.class).to eq(Net::HTTPOK)
  end
end
