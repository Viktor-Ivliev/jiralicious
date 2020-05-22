# encoding: utf-8
require "spec_helper"

describe Jiralicious, "Project Avatar" do
  before do
    Jiralicious.configure do |config|
      config.username = "jstewart"
      config.password = "topsecret"
      config.uri = "http://jstewart:topsecret@localhost"
      config.auth_type = :basic
      config.api_version = "latest"
    end

    rest_path = Jiralicious.rest_path.sub('jstewart:topsecret@', '')

    stub_request(
      :put, "#{rest_path}/project/EX/avatar/"
    ).to_return(status: 204)

    stub_request(
      :post, "#{rest_path}/project/EX/avatar/"
    ).to_return(status: 200)

    stub_request(
      :delete, "#{rest_path}/project/EX/avatar/10100"
    ).to_return(status: 200)

    stub_request(
      :get, "#{rest_path}/project/EX/avatars/"
    ).to_return(status: 200, body: avatar_list_json)

    stub_request(
      :get, "#{rest_path}/project/EX/avatars/"
    ).to_return(status: 200, body: avatar_list_json)

    stub_request(
      :post, "#{rest_path}/project/EX/avatar/temporary"
    ).to_return(status: 200, body: avatar_temp_json)
  end

  it "obtain project avatar list" do
    avatar = Jiralicious::Project::Avatar.avatars("EX")
    expect(avatar).to be_instance_of(Jiralicious::Project::Avatar)
    expect(avatar.system.count).to eq(2)
    expect(avatar.system[0].id).to eq("10100")
    expect(avatar.system[1].isSystemAvatar).to eq(true)
  end

  it "sends new project avatar" do
    file = "#{File.dirname(__FILE__)}/fixtures/avatar_test.png"
    avatar = Jiralicious::Project::Avatar.temporary("EX", filename: file, size: 4035)
    expect(avatar.needsCropping).to eq(true)
  end

  it "crops the current project avatar" do
    response = Jiralicious::Project::Avatar.post("EX", cropperWidth: 120,
                                                       cropperOffsetX: 50,
                                                       cropperOffsety: 50,
                                                       needsCropping: false)
    expect(response.response.class).to eq(Net::HTTPOK)
  end

  it "updates current project avatar" do
    response = Jiralicious::Project::Avatar.put("EX")
    expect(response.response.class).to eq(Net::HTTPNoContent)
  end

  it "updates current project avatar" do
    response = Jiralicious::Project::Avatar.remove("EX", 10100)
    expect(response.response.class).to eq(Net::HTTPOK)
  end
end
