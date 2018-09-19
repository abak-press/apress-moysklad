require 'spec_helper'

describe Apress::Moysklad::Presenters::Assortment do
  let(:client) { Apress::Moysklad::Api::Client.new('login', 'password') }

  let(:presenter) { described_class.new(client) }

  subject { presenter }

  its(:client) { is_expected.to eq client }

  describe '#expose' do
    let(:row) { Oj.load File.new('spec/fixtures/assortment.json'), symbol_keys: true }

    subject { presenter.expose(row) }

    it 'return hash' do
      is_expected.to eq __line__: 1,
                        __column__: 1,

                        id: '1a3cc760-eaf6-11e7-6b01-4b1d001d43a0',
                        code: '4547',
                        accountId: '5dde328f-99e6-11e7-7a69-971100003000',
                        externalCode: 'k8wwtsTajfpNw9MiHwbTq1',

                        article: 'К-001',
                        name: 'Конина',
                        description: 'Вкусная, полезная',

                        minPrice: 20_000.0,
                        pathName: 'Первый уровень/Второй уровень',
                        version: 1,

                        stock: 0.0,
                        reserve: 0.0,
                        inTransit: 0.0,
                        quantity: 0.0,

                        archived: false,
                        updated: '2017-12-27 16:11:07',

                        modificationsCount: 1,
                        weight: 1_000.0,
                        volume: 500.0,
                        vat: 0,
                        effectiveVat: 0,

                        meta: {type: 'product'},
                        buyPrice: {value: 10_000.0},

                        salePrices: [
                          {value: 0.0, priceType: 'опт'},
                          {value: 25_000.0, priceType: 'Розничная цена'}
                        ],

                        image: {
                          title: 'bug',
                          filename: 'bug.jpg',

                          size: 26_316,
                          updated: '2017-12-27 14:04:34',

                          meta: {
                            href: 'https://login:password@online.moysklad.ru/api/remap/1.1/download/' \
                                  'b878dab8-eaf5-11e7-7a31-d0fd001d9a46',
                            mediaType: 'application/octet-stream'
                          }
                        }
    end
  end
end
