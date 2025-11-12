# frozen_string_literal: true

module Apress
  module Moysklad
    module Presenters
      # Презентер для товарных групп МойСклад
      class Productfolders
        def expose(row)
          {
            id: row[:id],
            name: row[:name]
          }
        end
      end
    end
  end
end
