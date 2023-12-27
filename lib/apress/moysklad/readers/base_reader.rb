# frozen_string_literal: true

module Apress
  module Moysklad
    module Readers
      # Базовый класс загрузки сущностей из МойСклад
      #
      class BaseReader
        RETRY_ATTEMPTS = 5
        RETRY_CODES = [429, 500, 502, 503, 504, 1999, 1049, 1059].freeze
        MANY_REQUEST_CODE = 429
        ROWS_BATCH = 100

        class << self
          def allowed_options
            %i[login password]
          end
        end

        attr_reader :client

        def initialize(options)
          login = options.fetch(:login)
          password = options.fetch(:password)

          @client = Api::Client.new(login, password)
        end

        def each_row
          offset = 0

          loop do
            data = with_retry do
              get_data(offset)
            end

            check_rows_size! data, offset
            data[:rows].each { |row| yield presenter.expose(row) }

            break if (offset += ROWS_BATCH) >= data[:meta][:size]
          end
        end

        private

        def presenter
          raise 'You should implement this method'
        end

        def get_data(offset)
          raise 'You should implement this method'
        end

        def check_rows_size!(data, offset)
          actual_size = data[:rows].size
          expected_size = [data[:meta][:size] - offset, ROWS_BATCH].min

          raise "Invalid rows size, expect #{expected_size}, got #{actual_size}" if actual_size != expected_size
        end

        def with_retry(attempts = RETRY_ATTEMPTS)
          yield
        rescue Api::Error, Timeout::Error => e
          raise if e.is_a?(Api::Error) && !RETRY_CODES.include?(e.code)

          raise if (attempts -= 1) <= 0

          sleep(e.retry_interval) if e.is_a?(Api::Error) && e.code == MANY_REQUEST_CODE
          retry
        end
      end
    end
  end
end
