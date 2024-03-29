module Apress
  module Moysklad
    module Api
      # Ошибка при взаимодействии с API МойСклад
      class Error < StandardError
        attr_reader :code, :headers

        def initialize(msg, code = nil, headers = {})
          @code = code.to_i
          @headers = headers
          message = code ? "#{code} - #{msg}" : msg

          super message.force_encoding('UTF-8')
        end

        def retry_interval
          headers['x-lognex-retry-timeinterval'].to_i / 1000
        end
      end
    end
  end
end
