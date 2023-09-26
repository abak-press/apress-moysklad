# frozen_string_literal: true

module Apress
  module Moysklad
    module Presenters
      # Презентер для объектов типа - Изображение в МойСклад
      class Images
        def expose(row)
          row[:meta][:downloadHref]
        end
      end
    end
  end
end
