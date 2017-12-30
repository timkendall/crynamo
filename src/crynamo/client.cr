require "uri"
require "json"
require "http/client"
require "awscr-signer"
require "../aws"

AWS_SERVICE = "dynamodb"

module Crynamo
  # A low-level interface for connecting to a DynamoDB cluster and interating with it.
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

    # Fetches an item by key
    def get!(table : String, key : NamedTuple)
      marshalled = Crynamo::Marshaller.to_dynamo(key)

      query = {
        TableName: table,
        Key:       marshalled,
      }

      result = request("GetItem", query)
      # DynamoDB will return us an empty JSON object if nothing exists
      return {} of String => JSON::Type if !JSON.parse(result).as_h.has_key?("Item")

      Crynamo::Marshaller.from_dynamo(JSON.parse(result)["Item"].as_h)
    end

    # Inserts an item
    def put!(table : String, item : NamedTuple)
      marshalled = Crynamo::Marshaller.to_dynamo(item)

      query = {
        TableName: table,
        Item:      marshalled,
      }

      request("PutItem", query)
      return nil
    end

    # TODO
    def update!(table : String, key : NamedTuple, item : NamedTuple)
    end

    # Deletes an item at the specified key
    def delete!(table : String, key : NamedTuple)
      marshalled = Crynamo::Marshaller.to_dynamo(key)

      query = {
        TableName: table,
        Key:       marshalled,
      }

      request("DeleteItem", query)
      return nil
    end

    # TODO
    def query!(query : NamedTuple)
      # request("Query", query)
    end

    private def request(
                        operation : String,
                        payload : NamedTuple)
      response = @http.post(
        path: "/",
        body: payload.to_json,
        headers: HTTP::Headers{
          "Content-Type" => "application/x-amz-json-1.0",
          "X-Amz-Target" => "DynamoDB_20120810.#{operation}",
        },
      )
      status_code = response.status_code
      body = response.body

      # Note: Happy path, return what DynamoDB gives us
      return body if status_code == 200
      
      # Otherwise construct and AWS::Exception object
      exc = AWS::Exception.from_json(body)

      # Enumerate all AWS exceptions here
      # TODO Use a macro
      case exc.type
      when "ConditionalCheckFailedException"
        raise AWS::DynamoDB::Exceptions::ConditionalCheckFailedException.new(exc.message)
      when "ProvisionedThroughputExceededException"
        raise AWS::DynamoDB::Exceptions::ProvisionedThroughputExceededException.new(exc.message)
      when "ResourceNotFoundException"
        raise AWS::DynamoDB::Exceptions::ResourceNotFoundException.new(exc.message)
      when "ItemCollectionSizeLimitExceededException"
        raise AWS::DynamoDB::Exceptions::ItemCollectionSizeLimitExceededException.new(exc.message)
      else
        raise Exception.new(exc.message)
      end
    end
  end
end
