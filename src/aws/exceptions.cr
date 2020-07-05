# Encapsulates the errors common to the API actions of all AWS services. (note: hopefully this can be moved to a dedicated Crystal AWS shard at some point).
# See the official AWS documentation here https://docs.aws.amazon.com/amazondynamodb/latest/APIReference/CommonErrors.html
module AWS::Exceptions
  # Raised when you do not have sufficient access to perform the action.
  class AccessDeniedException < Exception
  end

  # Raised when request signature does not conform to AWS standards.
  class IncompleteSignature < Exception
  end

  # Raised when the request processing has failed because of an unknown error, exception or failure.
  class InternalFailure < Exception
  end

  # Raised when the action or operation requested is invalid. Verify that the action is typed correctly.
  class InvalidAction < Exception
  end

  # Raised when the X.509 certificate or AWS access key ID provided does not exist in our records.
  class InvalidClientTokenId < Exception
  end

  # Raised when parameters that must not be used together were used together.
  class InvalidParameterCombination < Exception
  end

  # Raised when an invalid or out-of-range value was supplied for the input parameter.
  class InvalidParameterValue < Exception
  end

  # Raised when the AWS query string is malformed or does not adhere to AWS standards.
  class InvalidQueryParameter < Exception
  end

  # Raised when the query string contains a syntax error.
  class MalformedQueryString < Exception
  end

  # Raised when the request is missing an action or a required parameter.
  class MissingAction < Exception
  end

  # Raised when the request must contain either a valid (registered) AWS access key ID or X.509 certificate.
  class MissingAuthenticationToken < Exception
  end

  # Raised when a required parameter for the specified action is not supplied.
  class MissingParameter < Exception
  end

  # Raised when the AWS access key ID needs a subscription for the service.
  class OptInRequired < Exception
  end

  # Raised when the request reached the service more than 15 minutes after the date stamp on the request or more than 15 minutes after the request expiration date (such as for pre-signed URLs), or the date stamp on the request is more than 15 minutes in the future.
  class RequestExpired < Exception
  end

  # Raised when the request has failed due to a temporary failure of the server.
  class ServiceUnavailable < Exception
  end

  # Raised when the request was denied due to request throttling.
  class ThrottlingException < Exception
  end

  # Raised when the input fails to satisfy the constraints specified by an AWS service.
  class ValidationError < Exception
  end

  # Raised when the input fails to satisfy the constraints specified by an AWS service.
  class ValidationException < Exception
  end
end
