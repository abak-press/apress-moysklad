# frozen_string_literal: true

module Apress
  module Moysklad
    # Сервис загрузки изображений по товару из акаунта МойСклад
    #
    # @example
    #   reader = Apress::Moysklad::Readers::Images.new(
    #      login: 'login',
    #      password: 'password'
    #      url: 'https://api.moysklad.ru/api/remap/1.2/entity/product/875d7130-d31d-11e9-0a80-025a002970c1/images'
    #    ).each_row { |row| puts row }
    module Readers
      class Images < BaseReader
        def initialize(options)
          super
          @url = options[:url]
        end

        private

        def presenter
          @presenter ||= Presenters::Images.new
        end

        def get_data(offset)
          client.send_request URI("#{@url}?offset=#{offset}&limit=#{ROWS_BATCH}")
        end
      end
    end
  end
end
