require 'spec_helper'

describe Apress::Moysklad::Api::Client do
  let(:client) { described_class.new('test@example.com', '123456') }

  subject { client }

  its(:login) { is_expected.to eq 'test@example.com' }
  its(:password) { is_expected.to eq '123456' }

  describe '#get' do
    context 'assortment' do
      subject { client.get(:assortment) }

      it 'get all rows from moysklad' do
        VCR.use_cassette 'get_assortment' do
          is_expected.to be_a(Hash) & include(:context, :meta, :rows)

          expect(subject[:rows]).to have(8).items
        end
      end

      context 'with limit and offset' do
        subject { client.get(:assortment, limit: 2, offset: 3) }

        it 'get selected rows from moysklad' do
          VCR.use_cassette 'get_assortment_with_limit_and_offset' do
            is_expected.to be_a(Hash) & include(:context, :meta, :rows)

            expect(subject[:rows]).to have(2).items
          end
        end
      end

      context 'with invalid params' do
        subject { client.get(:assortment, groupBy: 'foo') }

        it 'raise api error' do
          VCR.use_cassette 'get_assortment_with_invalid_params' do
            expect { subject }.to raise_error Apress::Moysklad::Api::Error, "1002 - Неопознанный путь: "\
                                                                           "https://api.moysklad.ru/api/remap/1.2/entity/assortment"
          end
        end
      end

      context 'when invalid login or password' do
        let(:client) { described_class.new('user@mail.com', 'password') }

        it 'raise api error' do
          VCR.use_cassette 'get_assortment_unauthorized' do
            expect { subject }.to raise_error Apress::Moysklad::Api::Error, '1056 - Ошибка аутентификации: '\
                                                                           'Неправильный пароль или имя пользователя'
          end
        end
      end
    end

    context 'invalid entity' do
      subject { client.get(:foo) }

      it 'raise api error' do
        VCR.use_cassette 'get_invalid_entity' do
          expect { subject }.to raise_error Apress::Moysklad::Api::Error, "1005 - Неизвестный тип: 'foo'"
        end
      end
    end

    context 'when 503 error' do
      subject { client.get(:assortment) }

      it do
        VCR.use_cassette 'get_assortment_503' do
          expect { subject }.to raise_error Apress::Moysklad::Api::Error, '503 - Service Unavailable'
        end
      end
    end
  end
end
