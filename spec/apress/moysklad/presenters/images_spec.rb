# frozen_string_literal: true
require 'spec_helper'
require 'oj'

describe Apress::Moysklad::Presenters::Images do
  let(:presenter) { described_class.new }

  subject { presenter }

  describe '#expose' do
    let(:row) { Oj.load File.new('spec/fixtures/image.json'), symbol_keys: true }

    subject { presenter.expose(row) }

    it 'return hash' do
      is_expected.to eq row[:meta][:downloadHref]
    end
  end
end
