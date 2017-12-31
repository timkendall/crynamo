require "../spec_helper"

describe Crynamo::Marshaller do
  it "marshalls Crystal types to DynamoDB types" do
    expected = {
      :name        => {"S" => "Scooby"},
      :age         => {"N" => 7},
      :is_cool     => {"BOOL" => true},
      :other_names => {"SS" => ["Scooby Doo", "Scooby Dooby Doo"]},
      :numbers     => {"NS" => [1, 2, 3, 4]},
      :list        => {"L" => [1, "foo", true]},
      :map         => {"M" => {foo: "bar"}},
      :empty       => {"NULL" => true},
    }
    Crynamo::Marshaller.to_dynamo({
      name:        "Scooby",
      age:         7,
      is_cool:     true,
      other_names: ["Scooby Doo", "Scooby Dooby Doo"],
      numbers:     [1, 2, 3, 4],
      list:        [1, "foo", true],
      map:         {foo: "bar"},
      empty:       nil,
    }).should eq(expected)
  end

  it "marshalls DynamoDB types to Crystal types" do
    expected = {
      :name        => "Scooby",
      :age         => 7.0,
      :is_cool     => true,
      :other_names => ["Scooby Doo", "Scooby Dooby Doo"],
      :numbers     => [1.0, 2.0, 3.0, 4.0],
      :list        => ["1", "foo", "true"],
      :map         => {foo: "bar"},
      :empty       => nil,
    }
    Crynamo::Marshaller.from_dynamo({
      :name        => {"S" => "Scooby"},
      :age         => {"N" => "7"},
      :is_cool     => {"BOOL" => true},
      :other_names => {"SS" => ["Scooby Doo", "Scooby Dooby Doo"]},
      :numbers     => {"NS" => ["1", "2", "3", "4"]},
      :list        => {"L" => ["1", "foo", "true"]},
      :map         => {"M" => {"foo": "bar"}},
      :empty       => {"NULL" => "true"},
    }).should eq(expected)
  end

  it "raises if Crystal type can't be marshalled" do
    expect_raises Crynamo::Marshaller::MarshallException, "Couldn't marshal Crystal type Regex to DynamoDB type" do
      Crynamo::Marshaller.to_dynamo({
        unsupported: /foo|bar/,
      })
    end
  end

  # Compiler doesn't like this one. Need to figure out
  # it "raises if DynamoDB type can't be marshalled" do
  #   expect_raises Crynamo::Marshaller::MarshallException, "Couldn't marshal DynamoDB type B to Crystal type" do
  #     # We don't support binary (Base64 encoded) types yet
  #     Crynamo::Marshaller.from_dynamo({
  #       "unsupported" => {"XX" => "dfx45fdgsfdg49sdg54244ds2sdgokfgsjf"},
  #     })
  #   end
  # end
end
