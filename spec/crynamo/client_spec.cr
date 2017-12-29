require "webmock"
require "../spec_helper"

CONFIG = Crynamo::Configuration.new(
  "foo", 
  "secret", 
  "us-east-1",
  "http://localhost:8000"
)

Spec.before_each &->WebMock.reset

describe Crynamo::Client do
  client = Crynamo::Client.new(CONFIG)

  it "it supports getting values" do
    WebMock.stub(:post, "http://localhost:8000/?")
      .with(body: "{\"TableName\":\"pets\",\"Key\":{\"name\":{\"S\":\"Scooby\"}}}")
      .to_return(status: 200, body: %({"Item":{"lifespan":{"N":"100"},"name":{"S":"Scooby"}}}))

    data = client.get("pets", { name: "Scooby" })

    data.should eq({
      "lifespan" => 100.0,
      "name" => "Scooby",
    })
  end

  it "it handles non-existent values" do
    WebMock.stub(:post, "http://localhost:8000/?")
      .with(body: "{\"TableName\":\"pets\",\"Key\":{\"name\":{\"S\":\"Missing\"}}}")
      .to_return(status: 200, body: "{}")

    data = client.get("pets", { name: "Missing" })
    
    data.should eq(nil)
  end
end