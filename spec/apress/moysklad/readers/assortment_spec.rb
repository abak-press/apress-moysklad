require 'spec_helper'

describe Apress::Moysklad::Readers::Assortment do
  let(:reader) { described_class.new(login: 'test@example.com', password: '123456') }

  subject { reader }

  its(:client) { is_expected.to be_a Apress::Moysklad::Api::Client }

  describe '#each_row' do
    let(:rows) { [] }

    subject do
      VCR.use_cassette 'read_assortment' do
        reader.each_row { |row| rows << row }
      end

      rows
    end

    it 'yields all rows from moysklad assortment' do
      is_expected.to have(5).items & all(be_a(Hash) & include(:id, :code, :name))

      expect(rows[0]).to include code: '00010', name: '123'
      expect(rows[1]).to include code: '00007', name: '1234567890' * 8
      expect(rows[2]).to include code: '00003', name: 'Ложка'
      expect(rows[3]).to include code: '4547', name: 'Конина'
      expect(rows[4]).to include code: '876555', name: 'балон'
    end

    context 'when api errors' do
      before do
        allow(reader.client).to receive(:get) do
          allow(reader.client).to receive(:get).and_call_original

          raise error # only first time
        end
      end

      context 'when retriable' do
        let(:error) { Apress::Moysklad::Api::Error.new('Internal server error', '500') }

        it { is_expected.to have(5).items }
      end

      context 'when not retriable' do
        let(:error) { Apress::Moysklad::Api::Error.new('Bad request', '400') }

        it { expect { subject }.to raise_error error }
      end
    end
  end
end
