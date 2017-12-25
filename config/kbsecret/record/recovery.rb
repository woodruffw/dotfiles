# frozen_string_literal: true

module KBSecret
  module Record
    # Represents a record containing a username and list of recovery codes.
    class Recovery < Abstract
      data_field :codes, sensitive: false, internal: true

      def populate_internal_fields
        defer_sync implicit: false do
          self.codes = []
        end
      end

      def load(*new_codes)
        codes.concat(new_codes)
        sync!
      end

      def next
        code = codes.pop
        sync!
        code
      end
    end
  end
end
