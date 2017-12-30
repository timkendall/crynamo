require "./dynamodb/**"

module AWS::DynamoDB
  # Represents the supported AWS DynamoDB operations (note: this is not exhaustive).
  enum Operation
    GetItem
    PutItem
    DeleteItem
  end
end
