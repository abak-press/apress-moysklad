# frozen_string_literal: true

require 'spec_helper'

describe Apress::Moysklad::Presenters::Assortment do
  let(:client) { Apress::Moysklad::Api::Client.new('login', 'password') }

  let(:presenter) { described_class.new(client) }

  subject { presenter }

  its(:client) { is_expected.to eq client }

  describe '#expose' do
    let(:row) { Oj.load File.new('spec/fixtures/assortment.json'), symbol_keys: true }
    let(:sale_price_type_url) do
      "https://api.moysklad.ru/api/remap/1.2/context/companysettings/pricetype/56fb6e43-d31d-11e9-0a80-01810016c891"
    end

    let(:expected_row) do
      {
        __line__: 1,
        __column__: 1,

        id: '875d7130-d31d-11e9-0a80-025a002970c1',
        code: '00001',
        accountId: '56bd4617-d31d-11e9-0a80-025300024b0d',
        externalCode: 'wyFpOzV1gcOJVnGyvJ--m1',

        article: '290307',
        name: 'Платье со сборкой на боку',
        description: "Состав: 90% тенсел, 10% лен\nСтрана-производитель: КИТАЙ",

        minPrice: {value: 500_000.0},
        pathName: 'Первый уровень/Второй уровень',

        stock: 0.0,
        reserve: 0.0,
        inTransit: 0.0,
        quantity: 0.0,

        archived: false,
        updated: '2020-09-14 11:01:21.392',

        weight: 1_000.0,
        volume: 1_000.0,
        vat: 10,
        effectiveVat: 10,

        meta: {type: 'product'},
        buyPrice: {value: 450_000.0},

        salePrices: [
          {
            priceType: {
              externalCode: "cbcf493b-55bc-11d9-848a-00112f43529a",
              id: "56fb6e43-d31d-11e9-0a80-01810016c891",
              meta: {
                href: sale_price_type_url,
                mediaType: "application/json",
                type: "pricetype",
              },
              name: "Цена продажи",
            },
            value: 500_000.0,
          },
        ],

        images: {
          meta: {
            href: 'https://api.moysklad.ru/api/remap/1.2/entity/product/875d7130-d31d-11e9-0a80-025a002970c1/images',
            size: 2,
          },
        },
        image_urls: [
          'https://login:password@api.moysklad.ru/api/remap/1.2/download/08d17b12-c10a-45b6-97ca-26d3853c3c03',
          'https://login:password@api.moysklad.ru/api/remap/1.2/download/999e6f35-6c88-43c9-a9c4-0c1dd7894df9',
        ],
      }
    end

    subject do
      VCR.use_cassette 'read_images' do
        presenter.expose(row)
      end
    end

    it 'return hash' do
      is_expected.to eq(expected_row)
    end

    context 'when retry error' do
      let(:error) { Apress::Moysklad::Api::Error.new('Too Many Requests', '429') }

      before do
        allow_any_instance_of(Apress::Moysklad::Readers::Images).to receive(:sleep)
        allow_any_instance_of(Apress::Moysklad::Api::Client).to receive(:send_request) do
          allow_any_instance_of(Apress::Moysklad::Api::Client).to receive(:send_request).and_call_original

          raise error # only first time
        end
      end

      it do
        is_expected.to eq(expected_row)
      end
    end
  end
end
