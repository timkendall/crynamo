module Crynamo
  # Represents the supported AWS DynamoDB operations (i.e actions)
  enum Operation
    GetItem
    PutItem
    UpdateItem
    DeleteItem
    Query
  end
end
