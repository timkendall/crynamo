require "json"
require "../aws/dynamodb"

module Crynamo
  module Marshaller
    extend self

    alias DynamoDB = AWS::DynamoDB
    
    alias Number = Int8 |
                   Int16 |
                   Int32 |
                   Int64 |
                   Float32 |
                   Float64

    class MarshallException < Exception
    end

    # Converts a `NamedTuple` to a DynamoDB `Hash` representation
    def to_dynamo(tuple : NamedTuple)
      hash = tuple.to_h
      keys = tuple.keys.to_a

      dynamodb_values = hash.values.map do |value|
        case value
        when String
          {DynamoDB::TypeDescriptor.string => value}
        when Number
          {DynamoDB::TypeDescriptor.number => value}
        when Bool
          {DynamoDB::TypeDescriptor.bool => value}
        when Array(String)
          {DynamoDB::TypeDescriptor.string_set => value}
        when Array(Int8), Array(Int16), Array(Int32), Array(Int64), Array(Float32), Array(Float64)
          {DynamoDB::TypeDescriptor.number_set => value}
        when Array, Tuple
          {DynamoDB::TypeDescriptor.list => value}
        when Hash, NamedTuple
          {DynamoDB::TypeDescriptor.map => value}
        when Nil
          {DynamoDB::TypeDescriptor.null => true}
        else
          raise MarshallException.new "Couldn't marshal Crystal type #{typeof(value)} to DynamoDB type"
        end
      end

      Hash.zip(keys, dynamodb_values)
    end

    # Converts a DynamoDB `Hash` representation to a regular Crystal `Hash`
    # TODO Convert to a `NamedTuple` instead
    def from_dynamo(item : Hash)
      keys = item.keys

      crystal_values = item.values.map do |value|
        dynamodb_type = value.as_h.first_key
        dynamodb_value = value.as_h.first_value

        case dynamodb_type
        when DynamoDB::TypeDescriptor.string
          dynamodb_value
        when DynamoDB::TypeDescriptor.number
          dynamodb_value.as_s.to_f32
        when DynamoDB::TypeDescriptor.bool
          dynamodb_value.as_bool
        when DynamoDB::TypeDescriptor.string_set
          dynamodb_value
            .as_a
            .map(&.as_s)
        when DynamoDB::TypeDescriptor.number_set
          dynamodb_value
            .as_a
            .map(&.as_s.to_f32)
        when DynamoDB::TypeDescriptor.list
          dynamodb_value.as_a
        when DynamoDB::TypeDescriptor.map
          # TODO Figure out what we need to do to cast to a generic Hash or NamedTuple
          # dynamodb_value.as(Hash(String, JSON::Type))
          # dynamodb_value.as(Hash)
          # JSON.parse(dynamodb_value.as(String)).as_h
          # dynamodb_value.as(NamedTuple)
          dynamodb_value
        when DynamoDB::TypeDescriptor.null
          nil
        else
          raise MarshallException.new "Couldn't marshal DynamoDB type #{typeof(dynamodb_type)} to Crystal type."
        end
      end
      
      Hash.zip(keys, crystal_values)
    end
  end
end
