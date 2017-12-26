module Crynamo
  struct Configuration
    property api_version, access_key_id, secret_access_key, region, endpoint

    def initialize(
      @access_key_id : String,
      @secret_access_key : String,
      @region : String,
      @endpoint : String,
      @api_version : String = "2012-08-10",
    )
    end
  end
end