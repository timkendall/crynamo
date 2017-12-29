require "uri"
require "json"
require "http/client"
require "awscr-signer"

AWS_SERVICE = "dynamodb"

module Crynamo
  class Client
    def initialize(@config : Crynamo::Configuration)
      uri = URI.parse(@config.endpoint)

      @http = HTTP::Client.new(uri)

      @http.before_request do |request|
        signer = Awscr::Signer::Signers::V4.new(
          AWS_SERVICE, 
          @config.region, 
          @config.access_key_id,
          @config.secret_access_key,
        )
        signer.sign(request)
      end
    end

    def get(table : String, key : NamedTuple)
      marshalled = Crynamo::Marshaller.to_dynamo(key)
      
      query = {
        TableName: table,
        Key: marshalled,
      }

      result = request("GetItem", query)
      error = result[:error]
      data = result[:data]

      # DynamoDB will return us an empty JSON object if nothing exists
      raise Exception.new("Error getting key #{key}") if data.nil?
      return nil if !JSON.parse(data).as_h.has_key?("Item")
      
      Crynamo::Marshaller.from_dynamo(JSON.parse(data)["Item"].as_h)
    end

    def put(table : String, item : NamedTuple)
      # TODO
    end
    
    def update(table : String, key : NamedTuple, item : NamedTuple)
      # TODO
    end

    def delete(table : String, key : NamedTuple)
      # TODO
    end

    def query(query : NamedTuple)
      request("Query", query)
    end

    private def request(
      operation : String, 
      payload : NamedTuple
    )
      response = @http.post(
        path: "/", 
        body: payload.to_json,
        headers: HTTP::Headers{
          "Content-Type" => "application/x-amz-json-1.0",
          "X-Amz-Target" => "DynamoDB_20120810.#{operation}"
        },
      )
      status_code = response.status_code
      body = response.body
      
      if status_code == 200
        { data: body, error: nil }
      else
        { data: nil, error: body }
      end
    end
  end
end
