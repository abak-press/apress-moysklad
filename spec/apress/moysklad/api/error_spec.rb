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
      expect(is_expected.target.retry_interval).to eq(3.0)
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

    context 'when x-lognex-reset is 0, but x-lognex-retry-after and x-lognex-retry-timeinterval is present' do
      let(:headers) do
        {
          'x-lognex-reset' => '0',
          'x-lognex-retry-after' => '1000',
          'x-lognex-retry-timeinterval' => '2000',
          'x-ratelimit-remaining' => '3'
        }
      end

      it do
        expect(is_expected.target.retry_interval).to eq(1)
      end
    end

    context 'when x-lognex-reset and x-lognex-retry-after is 0, but x-lognex-retry-timeinterval is present' do
      let(:headers) do
        {
          'x-lognex-reset' => '0',
          'x-lognex-retry-after' => '0',
          'x-lognex-retry-timeinterval' => '2000',
          'x-ratelimit-remaining' => '2'
        }
      end

      it do
        expect(is_expected.target.retry_interval).to eq(2)
      end
    end

    context 'when x-lognex-reset and x-lognex-retry-after and x-lognex-retry-timeinterval is 0' do
      let(:headers) do
        {
          'x-lognex-reset' => '0',
          'x-lognex-retry-after' => '0',
          'x-lognex-retry-timeinterval' => '0',
          'x-ratelimit-remaining' => '1'
        }
      end

      it do
        expect(is_expected.target.retry_interval).to eq(3)
      end
    end
  end
end
