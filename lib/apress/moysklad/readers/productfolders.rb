# frozen_string_literal: true
require 'apress/moysklad/api'
require 'apress/moysklad/presenters'
require 'apress/moysklad/readers/base_reader'
require 'timeout'

module Apress
  module Moysklad
    module Readers
      # Сервис загрузки товарных групп из акаунта МойСклад
      #
      # @example
      #   reader =
      #     Apress::Moysklad::Readers::Productfolders.new(login: 'login', password: 'password').each_row do |row|
      #       puts row
      #     end
      class Productfolders < BaseReader
        private

        ROWS_BATCH = 1_000

        def presenter
          @presenter ||= Presenters::Productfolders.new
        end

        def get_data(offset)
          client.get(:productfolder, offset: offset, limit: ROWS_BATCH)
        end
      end
    end
  end
end
