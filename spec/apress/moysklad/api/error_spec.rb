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
end
