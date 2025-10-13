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
  end
end
