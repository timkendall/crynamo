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

        puts request.headers
        puts request.body
      end
    end

    def get(table : String, key : NamedTuple)
      marshalled = Crynamo::Marshaller.to_dynamo(key)
      query = {
        TableName: table,
        Key: marshalled,
      } 
      request("GetItem", query)
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
      @http.post(
        path: "/", 
        body: payload.to_json,
        headers: HTTP::Headers{
          "Content-Type" => "application/x-amz-json-1.0",
          "X-Amz-Target" => "DynamoDB_20120810.#{operation}"
        },
      )
    end
  end
end
