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

  it "it supports inserting values" do
    # Mock the insertion request
    WebMock.stub(:post, "http://localhost:8000/?")
      .with(body: "{\"TableName\":\"pets\",\"Item\":{\"name\":{\"S\":\"Thor\"},\"age\":{\"N\":7},\"family_friendly\":{\"BOOL\":false}}}")
      .to_return(status: 200, body: "{}")
    # Mock the get request
    WebMock.stub(:post, "http://localhost:8000/?")
      .with(body: "{\"TableName\":\"pets\",\"Key\":{\"name\":{\"S\":\"Thor\"}}}")
      .to_return(status: 200, body: %({"Item":{"age":{"N":"7"},"family_friendly": {"BOOL": false},"name":{"S":"Thor"}}}))
 
    put_data = client.put("pets", { 
      name: "Thor",
      age: 7,
      family_friendly: false,
    })
    get_data = client.get("pets", { name: "Thor" })

    put_data.should eq(nil)

    get_data.should eq({
      "name" => "Thor",
      "age" => 7,
      "family_friendly" => false,
    })
  end
end