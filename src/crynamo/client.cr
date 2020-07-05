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
    def query!(
      table : String,
      key_condition_expression : String | Nil  = nil,
      flter_expression : String | Nil = nil,
      expression_attribute_values : NamedTuple | Nil = nil
    )
      marshalled = Crynamo::Marshaller.to_dynamo(expression_attribute_values)
      query = {
        TableName: table,
        Key:       marshalled,
      }

      result = request(AWS::DynamoDB::Operation::GetItem, query)
      # DynamoDB will return us an empty JSON object if nothing exists
      return {} of String => JSON::Any if !JSON.parse(result).as_h.has_key?("Item")

      Crynamo::Marshaller.from_dynamo(JSON.parse(result)["Item"].as_h)
    end

    # Fetches an item by key
    def get!(table : String, key : NamedTuple)
      marshalled = Crynamo::Marshaller.to_dynamo(key)
      query = {
        TableName: table,
        Key:       marshalled,
      }

      result = request(AWS::DynamoDB::Operation::GetItem, query)
      # DynamoDB will return us an empty JSON object if nothing exists
      return {} of String => JSON::Any if !JSON.parse(result).as_h.has_key?("Item")

      Crynamo::Marshaller.from_dynamo(JSON.parse(result)["Item"].as_h)
    end

    # Inserts an item
    def put!(table : String, item : NamedTuple)
      marshalled = Crynamo::Marshaller.to_dynamo(item)

      query = {
        TableName: table,
        Item:      marshalled,
      }

      request(AWS::DynamoDB::Operation::PutItem, query)
      return nil
    end

    # Deletes an item at the specified key
    def delete!(table : String, key : NamedTuple)
      marshalled = Crynamo::Marshaller.to_dynamo(key)

      query = {
        TableName: table,
        Key:       marshalled,
      }

      request(AWS::DynamoDB::Operation::DeleteItem, query)
      return nil
    end

    private def request(
      operation : AWS::DynamoDB::Operation,
      payload : NamedTuple
    )
      response = @http.post(
        path: "/",
        body: payload.to_json,
        headers: HTTP::Headers{
          "Content-Type" => "application/x-amz-json-1.0",
          "X-Amz-Target" => "DynamoDB_20120810.#{operation.to_s}",
        },
      )
      status_code = response.status_code
      body = response.body

      # Note: Happy path, return what DynamoDB gives us
      return body if status_code == 200

      # Otherwise construct and AWS::Exception object
      error = AWS::Error.from_json(body)

      # Define the general AWS API exceptions
      define_exception_handlers [
        "AccessDeniedException",
        "IncompleteSignature",
        "InternalFailure",
        "InvalidAction",
        "InvalidClientTokenId",
        "InvalidParameterCombination",
        "InvalidParameterValue",
        "InvalidQueryParameter",
        "MalformedQueryString",
        "MissingAction",
        "MissingAuthenticationToken",
        "MissingParameter",
        "OptInRequired",
        "RequestExpired",
        "ServiceUnavailable",
        "ThrottlingException",
        "ValidationError",
        "ValidationException"
      ], AWS::Exceptions

      # Define the DynamoDB-specific exceptions
      define_exception_handlers [
        "ConditionalCheckFailedException",
        "ProvisionedThroughputExceededException",
        "ResourceNotFoundException",
        "ItemCollectionSizeLimitExceededException",
      ], AWS::DynamoDB::Exceptions

      # Finally, raise a generic exception if none of the above match
      raise Exception.new(error.message)
    end

    private macro define_exception_handlers(exceptions, mmodule)
      {% begin %}
        case error.type
        {% for exception in exceptions %}
          when {{exception}}
            raise {{mmodule.id}}::{{exception.id}}.new(error.message)
        {% end %}
        end
      {% end %}
    end
  end
end
