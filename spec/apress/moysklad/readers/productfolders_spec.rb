# frozen_string_literal: true
require 'spec_helper'

describe Apress::Moysklad::Readers::Productfolders do
  let(:reader) do
    described_class.new(
      login: 'test@example.com',
      password: '123456',
      url: 'https://api.moysklad.ru/api/remap/1.2/entity/productfolder'
    )
  end

  subject { reader }

  its(:client) { is_expected.to be_a Apress::Moysklad::Api::Client }

  describe '#each_row' do
    let(:rows) { [] }

    subject do
      VCR.use_cassette 'read_productfolders' do
        reader.each_row { |row| rows << row }
      end

      rows
    end

    it 'yields all rows from moysklad productfolders' do
      is_expected.to have(3).items

      expect(rows[0]).to eq(id: '3f89784b-e44e-11ef-0a80-07a700549e06', name: 'Товары интернет-магазинов')
      expect(rows[1]).to eq(id: '3f89e42d-e44e-11ef-0a80-07a700549e07', name: 'тест')
      expect(rows[2]).to eq(id: 'b426bcff-ef51-11ef-0a80-085800428c6e', name: '123')
    end
  end
end
