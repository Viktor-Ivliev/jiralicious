# encoding: utf-8
require "spec_helper"

describe Jiralicious, "Project Versions Class: " do
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
      :post, "#{rest_path}/version/"
    ).to_return(status: 200, body: version_json)

    stub_request(
      :get, "#{rest_path}/version/10000"
    ).to_return(status: 200, body: version_json)

    stub_request(
      :delete, "#{rest_path}/version/10000"
    ).to_return(status: 200, body: nil)

    stub_request(
      :put, "#{rest_path}/version/10000"
    ).to_return(status: 200, body: version_updated_json)

    stub_request(
      :get, "#{rest_path}/version/10000/relatedIssueCounts"
    ).to_return(status: 200, body: version_ric_json)

    stub_request(
      :get, "#{rest_path}/version/10000/unresolvedIssueCount"
    ).to_return(status: 200, body: version_uic_json)
  end

  it "find a version" do
    version = Jiralicious::Version.find(10000)
    expect(version.version_key).to eq("10000")
    expect(version.name).to eq("Version 1")
    expect(version.userReleaseDate).to eq("5/Jul/2010")
    expect(version.archived).to eq(false)
  end

  it "create a new version" do
    version = Jiralicious::Version.create(description: "An excellent version", name: "Version 1", archived: false, released: true, releaseDate: "2010-07-05", project: "DEMO")
    expect(version.version_key).to eq("10000")
    expect(version.name).to eq("Version 1")
    expect(version.userReleaseDate).to eq("5/Jul/2010")
    expect(version.archived).to eq(false)
  end

  it "update a version" do
    version = Jiralicious::Version.update(10000, name: "Version 2", description: "This is a JIRA version. Updated Version.", project: "DEMO")
    expect(version.version_key).to eq("10000")
    expect(version.name).to eq("Version 2")
    expect(version.userReleaseDate).to eq("5/Jul/2010")
    expect(version.archived).to eq(false)
    expect(version.description).to eq("This is a JIRA version. Updated Version.")
  end

  it "delete a version" do
    version = Jiralicious::Version.remove(10000)
    expect(version).to be_nil
  end

  it "version related issue count" do
    version = Jiralicious::Version.find(10000)
    count = version.related_issue_counts
    expect(count.issuesFixedCount).to eq(23)
    expect(count.issuesAffectedCount).to eq(101)
  end

  it "version unresolved issue count" do
    version = Jiralicious::Version.find(10000)
    count = version.unresolved_issue_count
    expect(count).to eq(23)
  end
end
