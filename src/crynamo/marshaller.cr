require "json"
require "./data_type_descriptors"

module Crynamo
  module Marshaller
    extend self

    alias Number = Int8 |
                   Int16 |
                   Int32 |
                   Int64 |
                   Float32 |
                   Float64

    class MarshallException < Exception
    end

    def to_dynamo(tuple : NamedTuple)
      hash = tuple.to_h
      keys = tuple.keys.to_a

      dynamodb_values = hash.values.map do |value|
        case value
        when String
          {DataTypeDescriptor.string => value}
        when Number
          {DataTypeDescriptor.number => value}
        when Bool
          {DataTypeDescriptor.bool => value}
        when Array(String)
          {DataTypeDescriptor.string_set => value}
        when Array(Int8), Array(Int16), Array(Int32), Array(Int64), Array(Float32), Array(Float64)
          {DataTypeDescriptor.number_set => value}
        when Array, Tuple
          {DataTypeDescriptor.list => value}
        when Hash, NamedTuple
          {DataTypeDescriptor.map => value}
        when Nil
          {DataTypeDescriptor.null => true}
        else
          raise MarshallException.new "Couldn't marshal Crystal type #{typeof(value)} to DynamoDB type"
        end
      end

      Hash.zip(keys, dynamodb_values)
    end

    def from_dynamo(body : String)
      hash = JSON.parse(body)
      item = hash["Item"].as_h
      keys = item.keys

      crystal_values = item.values.map do |value|
        value_hash =  value.as(Hash(String, JSON::Type))
        dynamodb_type = value_hash.first_key
        dynamodb_value = value_hash.first_value

        case dynamodb_type
        when DataTypeDescriptor.string
          dynamodb_value
        when DataTypeDescriptor.number
          dynamodb_value.as(String).to_f32
        when DataTypeDescriptor.bool
          dynamodb_value.as(Bool)
        when DataTypeDescriptor.string_set
          dynamodb_value.as(Array(JSON::Type))
        when DataTypeDescriptor.number_set
          dynamodb_value.as(Array(JSON::Type))
        when DataTypeDescriptor.list
          dynamodb_value.as(Array)
        when DataTypeDescriptor.map
          dynamodb_value.as(Hash)
        when DataTypeDescriptor.null
          nil
        else
          raise MarshallException.new "Couldn't marshal DynamoDB type #{typeof(dynamodb_type)} to Crystal type."
        end
      end
      
      Hash.zip(keys, crystal_values)
    end
  end
end
