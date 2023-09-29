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
        private

        def presenter
          @presenter ||= Presenters::Assortment.new(client)
        end

        def get_data(offset)
          client.get(
            :assortment,
            limit: ROWS_BATCH, offset: offset, groupBy: :product, filter: 'archived=false;archived=true'
          )
        end
      end
    end
  end
end
