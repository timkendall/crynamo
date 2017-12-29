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

      dynamodb_values = hash.map do |key, value|
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
          raise MarshallException.new "Couldn't marshal type #{typeof(value)}"
        end
      end

      Hash.zip(keys, dynamodb_values)
    end

    def from_dynamo(json : JSON::Any)
    end
  end
end
