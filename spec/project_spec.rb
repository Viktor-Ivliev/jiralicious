# encoding: utf-8
require "spec_helper"

describe Jiralicious, "Project Management Class: " do
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
      :get, "#{rest_path}/project/"
    ).to_return(status: 200, body: projects_json)

    stub_request(
      :get, "#{rest_path}/project/EX"
    ).to_return(status: 200, body: project_json)

    stub_request(
      :get, "#{rest_path}/project/EX/components"
    ).to_return(status: 200, body: project_componets_json)

    stub_request(
      :get, "#{rest_path}/project/EX/versions"
    ).to_return(status: 200, body: project_versions_json)

    stub_request(
      :get, "#{rest_path}/project/ABC"
    ).to_return(status: 200, body: project_json)

    stub_request(
      :post, "#{rest_path}/search"
    ).to_return(status: 200, body: project_issue_list_json)
  end

  it "finds all projects" do
    projects = Jiralicious::Project.all
    expect(projects).to be_instance_of(Jiralicious::Project)
    expect(projects.count).to eq(2)
    expect(projects.EX.id).to eq("10000")
  end

  it "finds project issue list class level" do
    issues = Jiralicious::Project.issue_list("EX")
    expect(issues).to be_instance_of(Jiralicious::Issue)
    expect(issues.count).to eq(2)
    expect(issues.EX_1["id"]).to eq("10000")
  end

  it "finds project issue list instance level" do
    project = Jiralicious::Project.find("EX")
    issues = project.issues
    expect(issues).to be_instance_of(Jiralicious::Issue)
    expect(issues.count).to eq(2)
    expect(issues.EX_1["id"]).to eq("10000")
  end

  it "finds project componets" do
    components = Jiralicious::Project.components("EX")
    expect(components.count).to eq(2)
    expect(components.id_10000.name).to eq("Component 1")
    expect(components.id_10050.name).to eq("PXA")
  end

  it "finds project versions class level" do
    versions = Jiralicious::Project.versions("EX")
    expect(versions.count).to eq(2)
    expect(versions.id_10000.name).to eq("New Version 1")
    expect(versions.id_10000.overdue).to eq(true)
    expect(versions.id_10010.name).to eq("Next Version")
    expect(versions.id_10010.overdue).to eq(false)
  end

  it "finds project versions instance level" do
    project = Jiralicious::Project.find("EX")
    versions = project.versions
    expect(versions.count).to eq(2)
    expect(versions.id_10000.name).to eq("New Version 1")
    expect(versions.id_10000.overdue).to eq(true)
    expect(versions.id_10010.name).to eq("Next Version")
    expect(versions.id_10010.overdue).to eq(false)
  end
end
