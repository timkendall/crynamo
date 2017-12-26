require "http/client"

module Crynamo
  class Client
    def initialize(@config : Crynamo::Configuration)
      # TODO Setup auth signing stuff
    end

    def get(table : String, key : NamedTuple)
      response = request(
        "AWS-Signed-Credentials",
        Operations::GetItem,
        {
          TableName: table,
          Key: key,
        }
      )
      response.body
    end

    def put
      # TODO
    end
    
    def update
      # TODO
    end

    def delete
      # TODO
    end

    private def request(
      authorization : String, 
      operation : Operations, 
      payload : NamedTuple
    )
      headers =  HTTP::Headers{
        "Authorization" => "AWS-Signed-Credentials",
        "Content-Type" => "application/x-amz-json-1.0",
        "X-Amz-Target" => "DynamoDB_20120810.#{operation}"
      }

      HTTP::Client.post(
        @config.endpoint, 
        headers: headers,
        body: payload,
      )
    end
  end
end
