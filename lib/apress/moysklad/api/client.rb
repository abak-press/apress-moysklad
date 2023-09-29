# frozen_string_literal: true

require 'net/http'
require 'openssl'
require 'uri'

require 'oj'

module Apress
  module Moysklad
    module Api
      # Клиент для взаимодействия с API МойСклад
      #
      # @example
      #   client = Apress::Moysklad::Api::Client.new('login', 'password')
      #
      #   client.get(:assortment, limit: 2)
      #   => {:context=>...}
      class Client
        API_URL = 'https://api.moysklad.ru/api/remap'
        API_VERSION = '1.2'

        TIMEOUT = 60 # seconds
        HEADERS = {
          'Accept-Encoding' => 'gzip',
        }.freeze

        attr_reader :login, :password

        def initialize(login, password)
          @login = login
          @password = password
        end

        def get(entity, params = {})
          uri = api_uri(entity)
          uri.query = URI.encode_www_form(params) unless params.empty?

          send_request(uri)
        end

        def send_request(uri)
          req = Net::HTTP::Get.new(uri)
          req.basic_auth login, password
          HEADERS.each do |header, value|
            req.add_field(header, value)
          end
          res = Net::HTTP.start(uri.hostname, uri.port, http_options) do |http|
            http.request(req)
          end

          parse_response(res)
        end

        private

        def api_uri(entity)
          URI "#{API_URL}/#{API_VERSION}/entity/#{entity}"
        end

        def http_options
          {
            open_timeout: TIMEOUT,
            read_timeout: TIMEOUT,
            use_ssl: true,
          }
        end

        def parse_response(res)
          Oj.load(res.body, symbol_keys: true, mode: :compat).tap do |data|
            if data.key? :errors
              err = data[:errors].first

              raise Api::Error.new(err[:error], err[:code])
            end

            raise Api::Error.new(res.msg, res.code, res.each_header.to_h) unless res.is_a? Net::HTTPOK
          end
        end
      end
    end
  end
end
