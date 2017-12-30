# Encapsulates errors specific to DynamoDB operations. See https://docs.aws.amazon.com/amazondynamodb/latest/APIReference/API_Operations_Amazon_DynamoDB.html for official documentation
module AWS::DynamoDB::Exceptions
  # Raised when a condition specified in the operation could not be evaluated.
  class ConditionalCheckFailedException < Exception
  end

  # Raised when your request rate is too high.
  class ProvisionedThroughputExceededException < Exception
  end

  # Raised when the operation tried to access a nonexistent table or index. The resource might not be specified correctly, or its status might not be ACTIVE.
  class ResourceNotFoundException < Exception
  end

  # Raised when an item collection is too large.
  class ItemCollectionSizeLimitExceededException < Exception
  end
end
