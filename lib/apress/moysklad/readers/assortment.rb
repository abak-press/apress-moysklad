require 'apress/moysklad/api'
require 'apress/moysklad/presenters'
require 'apress/moysklad/readers/base_reader'
require 'apress/moysklad/readers/images'
require 'timeout'

module Apress
  module Moysklad
    module Readers
      # Сервис загрузки ассортимента из акаунта МойСклад
      #
      # @example
      #   reader = Apress::Moysklad::Readers::Assortment.new(
      #                                                        login: 'login',
      #                                                        password: 'password'
      #                                                      ).each_row { |row| puts row }
      class Assortment < BaseReader
        class << self
          def allowed_options
            super + %i[categories]
          end
        end

        def initialize(options)
          @categories = options.fetch(:categories, '').split(',')

          super
        end

        def each_row
          if @categories.empty?
            each_row_offset_loop(nil) { |row| yield presenter.expose(row) }
          else
            @categories.each_slice(CATEGORIES_BATCH) do |categories_slice|
              each_row_offset_loop(categories_filter(categories_slice)) { |row| yield presenter.expose(row) }
            end
          end
        end

        private

        CATEGORIES_BATCH = 60

        def presenter
          @presenter ||= Presenters::Assortment.new(client)
        end

        def each_row_offset_loop(categories_filter, &block)
          offset = 0

          loop do
            data = with_retry do
              get_data(offset, categories_filter)
            end

            check_rows_size! data, offset
            data[:rows].each { |row| block.call row }

            break if (offset += ROWS_BATCH) >= data[:meta][:size]
          end
        end

        def get_data(offset, categories_filter = nil)
          client.get(
            :assortment,
            limit: ROWS_BATCH,
            offset: offset,
            groupBy: :product,
            filter: ['archived=false;archived=true', categories_filter].compact.join(';')
          )
        end

        def categories_filter(categories)
          categories.map do |category|
            client.category_param_for_filter(category)
          end.join(';')
        end
      end
    end
  end
end
