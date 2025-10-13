require 'spec_helper'

describe Apress::Moysklad::Api::Error do
  let(:error) { described_class.new('Message', '999') }

  subject { error }

  its(:code) { is_expected.to eq 999 }
  its(:to_s) { is_expected.to eq '999 - Message' }

  context 'without code' do
    let(:error) { described_class.new('Ошибка!') }

    its(:code) { is_expected.to eq 0 }
    its(:to_s) { is_expected.to eq 'Ошибка!' }
  end

  context '#retry_interval' do
    let(:headers) { {} }
    let(:error) { described_class.new('Message', '999', headers) }

    it do
      expect(is_expected.target.retry_interval).to be_nil
    end

    context 'when headers has x-lognex-retry-after' do
      let(:headers) { {'x-lognex-retry-after' => '60000'} }

      it do
        expect(is_expected.target.retry_interval).to eq(60)
      end

      context 'when x-lognex-retry-after < 10000' do
        let(:headers) { {'x-lognex-retry-after' => '6500'} }

        it do
          expect(is_expected.target.retry_interval).to eq(6.5)
        end
      end
    end
  end
end
