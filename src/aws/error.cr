require "json"

module AWS
  # Represents an error returned from an AWS API
  class Error
    JSON.mapping(
      __type: String,
      message: String,
    )

    # Get's the human-readable error type
    def type
      @__type.split("#").last
    end
  end
end
