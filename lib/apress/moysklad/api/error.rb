module Apress
  module Moysklad
    module Api
      # Ошибка при взаимодействии с API МойСклад
      class Error < StandardError
        attr_reader :code

        def initialize(msg, code = nil)
          @code = code.to_i

          message = code ? "#{code} - #{msg}" : msg

          super message.force_encoding('UTF-8')
        end
      end
    end
  end
end
