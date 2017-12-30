require "json"

module AWS
  # Represents an exception returned from an AWS API
  class Exception
    JSON.mapping(
      __type: String,
      message: String,
    )

    # Get's the human-readable exception type
    def type
      @__type.split("#").last
    end
  end
end