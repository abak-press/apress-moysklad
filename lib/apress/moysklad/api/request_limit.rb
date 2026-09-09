module Apress
  module Moysklad
    module Api
      class RequestLimit
        REQUEST_COST = 4
        DEFAULT_RESET_TIME = 3_000

        attr_reader :headers

        def initialize(headers)
          @headers = headers
        end

        def call
          return if rate_limit.nil? || rate_limit >= REQUEST_COST

          sleep(reset_time)
        end

        private

        # Время через которое можно начать следующую пачку запросов
        #   См. документацию https://dev.moysklad.ru/doc/api/remap/1.2/#/general#1-mojsklad-json-api
        #   X-Lognex-Reset - время до сброса ограничения в миллисекундах. Равно нулю, если ограничение не установлено
        #   X-Lognex-Retry-After - время до сброса ограничения в миллисекундах.
        #   X-Lognex-Retry-TimeInterval - интервал в миллисекундах, в течение которого можно сделать эти запросы
        def reset_time
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

          reset_time / 1_000
        end

        # Число запросов, которые можно отправить до получения 429 ошибки
        def rate_limit
          headers['x-ratelimit-remaining']&.to_i
        end
      end
    end
  end
end
