# encoding: utf-8
require "spec_helper"

describe Jiralicious, "Project Avatar" do
  before :each do
    Jiralicious.configure do |config|
      config.username = "jstewart"
      config.password = "topsecret"
      config.uri = "http://localhost"
      config.auth_type = :basic
      config.api_version = "latest"
    end

    rest_path = Jiralicious.rest_path.sub('jstewart:topsecret@', '')

    stub_request(
      :put, "#{rest_path}/user/avatar/"
    ).to_return(status: 204)

    stub_request(
      :post, "#{rest_path}/user/avatar/"
    ).to_return(status: 200)

    stub_request(
      :delete, "#{rest_path}/user/avatar/10100?username=fred"
    ).to_return(status: 200)

    stub_request(
      :get, "#{rest_path}/user/avatars?username=fred"
    ).to_return(status: 200, body: avatar_list_json)

    stub_request(
      :post, "#{rest_path}/user/avatar/temporary"
    ).to_return(status: 200, body: avatar_temp_json)
  end

  it "obtain user avatar list" do
    avatar = Jiralicious::User::Avatar.avatars("fred")
    expect(avatar).to be_instance_of(Jiralicious::User::Avatar)
    expect(avatar.system.count).to eq(2)
    expect(avatar.system[0].id).to eq("10100")
    expect(avatar.system[1].isSystemAvatar).to eq(true)
  end

  it "sends new user avatar" do
    file = "#{File.dirname(__FILE__)}/fixtures/avatar_test.png"
    avatar = Jiralicious::User::Avatar.temporary("fred", filename: file, size: 4035)
    expect(avatar.needsCropping).to eq(true)
  end

  it "crops the current user avatar" do
    response = Jiralicious::User::Avatar.post("fred", cropperWidth: 120,
                                                      cropperOffsetX: 50,
                                                      cropperOffsety: 50,
                                                      needsCropping: false)
    expect(response.response.class).to eq(Net::HTTPOK)
  end

  it "updates current user avatar" do
    response = Jiralicious::User::Avatar.put("fred")
    expect(response.response.class).to eq(Net::HTTPNoContent)
  end

  it "updates current user avatar" do
    response = Jiralicious::User::Avatar.remove("fred", 10100)
    expect(response.response.class).to eq(Net::HTTPOK)
  end
end
