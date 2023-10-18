# frozen_string_literal: true
require 'spec_helper'

describe Apress::Moysklad::Readers::Images do
  let(:reader) do
    described_class.new(
      login: 'test@example.com',
      password: '123456',
      url: 'https://api.moysklad.ru/api/remap/1.2/entity/product/875d7130-d31d-11e9-0a80-025a002970c1/images'
    )
  end

  subject { reader }

  its(:client) { is_expected.to be_a Apress::Moysklad::Api::Client }

  describe '#each_row' do
    let(:rows) { [] }

    subject do
      VCR.use_cassette 'read_images' do
        reader.each_row { |row| rows << row }
      end

      rows
    end

    it 'yields all rows from moysklad images' do
      is_expected.to have(2).items & all(be_a(String))

      expect(rows[0]).to eq('https://api.moysklad.ru/api/remap/1.2/download/08d17b12-c10a-45b6-97ca-26d3853c3c03')
      expect(rows[1]).to eq('https://api.moysklad.ru/api/remap/1.2/download/999e6f35-6c88-43c9-a9c4-0c1dd7894df9')
    end

    context 'when api errors' do
      before do
        allow(reader.client).to receive(:send_request) do
          allow(reader.client).to receive(:send_request).and_call_original

          raise error # only first time
        end
      end

      context 'when retriable' do
        let(:error) { Apress::Moysklad::Api::Error.new('Internal server error', '500') }

        it { is_expected.to have(2).items }

        context 'when 429' do
          let(:error) { Apress::Moysklad::Api::Error.new('Too Many Requests', '429') }
          before { expect_any_instance_of(described_class).to receive(:sleep) }

          it { is_expected.to have(2).items }
        end
      end

      context 'when not retriable' do
        let(:error) { Apress::Moysklad::Api::Error.new('Bad request', '400') }

        it { expect { subject }.to raise_error error }
      end
    end
  end
end
