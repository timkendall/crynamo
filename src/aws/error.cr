require "json"

module AWS
  # Represents an error returned from an AWS API
  class Error
    include JSON::Serializable
    property __type : String
    property message : String

    # Get's the human-readable error type
    def type
      @__type.split("#").last
    end
  end
end
