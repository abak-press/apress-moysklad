module Apress
  module Moysklad
    module Api
      # Ошибка при взаимодействии с API МойСклад
      class Error < StandardError
        DEFAULT_RESET_TIME = 3_000

        attr_reader :code, :headers

        def initialize(msg, code = nil, headers = {})
          @code = code.to_i
          @headers = headers
          message = code ? "#{code} - #{msg}" : msg

          super message.force_encoding('UTF-8')
        end

        def retry_interval
          reset_ms = headers['x-lognex-reset'].to_i
          retry_after_ms = headers['x-lognex-retry-after'].to_i
          retry_interval_ms = headers['x-lognex-retry-timeinterval'].to_i

          reset_time = if reset_ms > 0
                         reset_ms
                       elsif retry_after_ms > 0
                         retry_after_ms
                       elsif retry_interval_ms > 0
                         retry_interval_ms
                       else
                         DEFAULT_RESET_TIME
                       end

          reset_time.to_f / 1_000
        end
      end
    end
  end
end
