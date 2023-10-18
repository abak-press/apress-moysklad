module Apress
  module Moysklad
    module Presenters
      # Презентер для объектов типа - Ассортимент в МойСклад
      #
      # @example
      #   client = Apress::Moysklad::Api::Client.new('login', 'password')
      #   presenter = Apress::Moysklad::Presenters::Assortment.new(client)
      #
      #   row = client.get(:assortment)[:rows].first
      #   presenter.expose(row)
      #   => {:__line__=>1, :__column__=>1, :id=>"1a3cc760-eaf6-11e7-6b01-4b1d001d43a0", ...}
      class Assortment
        ATTRIBUTES = [
          :id,
          :code,
          :accountId,
          :externalCode,

          :article,
          :name,
          :description,

          :pathName,
          :version,

          :stock,
          :reserve,
          :inTransit,
          :quantity,

          :archived,
          :updated,

          :modificationsCount,
          :weight,
          :volume,
          :vat,
          :effectiveVat,

          meta: [:type].freeze,
          images: [meta: [:href, :size].freeze].freeze,
          minPrice: [:value].freeze,
          buyPrice: [:value].freeze,
          salePrices: [:value, :priceType].freeze
        ].freeze

        attr_reader :client

        def initialize(client)
          @client = client
          @counter = 0
        end

        def expose(row)
          record = {
            __line__: @counter += 1,
            __column__: 1
          }

          record.merge! filter(row)
          if record[:images] && record[:images][:meta][:size] > 0
            record[:image_urls] = image_urls(record[:images][:meta][:href])
          end
          record
        end

        private

        def auth_to_link!(link)
          link.sub!(%r{://}, "://#{client.login}:#{client.password}@")
        end

        def filter(row, attrs = ATTRIBUTES)
          attrs.each_with_object({}) do |key, result|
            if key.is_a? Hash
              key.each do |hash_key, hash_attrs|
                next unless row.key? hash_key

                result[hash_key] =
                  if row[hash_key].is_a? Array
                    row[hash_key].map { |item| filter(item, hash_attrs) }
                  else
                    filter(row[hash_key], hash_attrs)
                  end
              end
            elsif row.key? key
              result[key] = row[key]
            end
          end
        end

        def image_urls(url)
          images = []
          Readers::Images.new(login: client.login, password: client.password, url: url).each_row do |row|
            images << auth_to_link!(row)
          end
          images
        end
      end
    end
  end
end
