# frozen_string_literal: true
require 'spec_helper'
require 'oj'

describe Apress::Moysklad::Presenters::Productfolders do
  let(:presenter) { described_class.new }

  subject { presenter }

  describe '#expose' do
    let(:row) { Oj.load File.new('spec/fixtures/productfolders.json'), symbol_keys: true }

    subject { presenter.expose(row) }

    it 'return hash' do
      is_expected.to eq(id: '3f89784b-e44e-11ef-0a80-07a700549e06', name: 'Товары интернет-магазинов')
    end
  end
end
