module Apress
  module Moysklad
    module Api
      class RequestLimit
        REQUEST_COST = 4

        attr_reader :headers

        def initialize(headers)
          @headers = headers
        end

        def call
          return if rate_limit.nil? || rate_limit >= REQUEST_COST

          sleep(reset_time)
        end

        private

        def reset_time
          headers['x-lognex-reset'].to_f / 1_000
        end

        def rate_limit
          headers['x-ratelimit-remaining']&.to_i
        end
      end
    end
  end
end
