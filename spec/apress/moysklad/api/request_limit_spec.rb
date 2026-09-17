# frozen_string_literal: true

require 'spec_helper'

describe Apress::Moysklad::Api::RequestLimit do
  describe '#call' do
    let(:headers) { {'x-lognex-reset' => '60000', 'x-ratelimit-remaining' => '44'} }
    let(:service) { described_class.new(headers) }

    subject { service.call }

    it do
      expect(service).not_to receive(:sleep)

      is_expected.to be_nil
    end

    context 'when missing headers' do
      let(:headers) { {} }

      it do
        expect(service).not_to receive(:sleep)

        is_expected.to be_nil
      end
    end

    context 'when rate_limit is zero' do
      let(:headers) { {'x-lognex-reset' => '60000', 'x-ratelimit-remaining' => '0'} }

      it do
        expect(service).to receive(:sleep).with(60)

        is_expected
      end
    end

    context 'when rate_limit is less than request cost' do
      let(:headers) { {'x-lognex-reset' => '60000', 'x-ratelimit-remaining' => '3'} }

      it do
        expect(service).to receive(:sleep).with(60)

        is_expected
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
          expect(service).to receive(:sleep).with(1)

          is_expected
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
          expect(service).to receive(:sleep).with(2)

          is_expected
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
          expect(service).to receive(:sleep).with(3)

          is_expected
        end
      end
    end
  end
end
