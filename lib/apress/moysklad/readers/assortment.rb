require 'apress/moysklad/api'
require 'apress/moysklad/presenters'
require 'timeout'

module Apress
  module Moysklad
    module Readers
      # Сервис загрузки ассортимента из акаунта МойСклад
      #
      # @example
      #   reader = Apress::Moysklad::Readers::Assortment.new('login', 'password').each_row { |row| puts row }
      class Assortment
        RETRY_ATTEMPTS = 5
        RETRY_CODES = [500, 502, 503, 504, 1999].freeze

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
          presenter = Presenters::Assortment.new(client)

          loop do
            data = with_retry do
              client.get(:assortment, limit: ROWS_BATCH, offset: offset, scope: :product, archived: :All)
            end

            check_rows_size! data, offset

            data[:rows].each { |row| yield presenter.expose(row) }

            break if (offset += ROWS_BATCH) >= data[:meta][:size]
          end
        end

        private

        def check_rows_size!(data, offset)
          actual_size = data[:rows].size
          expected_size = [data[:meta][:size] - offset, ROWS_BATCH].min

          raise "Invalid rows size, expect #{expected_size}, got #{actual_size}" if actual_size != expected_size
        end

        def with_retry(attempts = RETRY_ATTEMPTS)
          yield
        rescue Api::Error, Timeout::Error => err
          raise if err.is_a?(Api::Error) && !RETRY_CODES.include?(err.code)

          (attempts -= 1) > 0 ? retry : raise
        end
      end
    end
  end
end
