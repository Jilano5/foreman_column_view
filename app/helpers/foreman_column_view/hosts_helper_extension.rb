module ForemanColumnView
  module HostsHelperExtension
    extend ActiveSupport::Concern

    module Overrides
      # Extend core HostsHelper to add rows to Properties on the legacy hosts/show
      def overview_fields(host)
        fields = super
        cache = {}

        ForemanColumnView::Columns.for_view(:hosts_properties).each do |name, opts|
          next unless ForemanColumnView::Columns.visible?(host, name)

          # This won't work well with i18n, use row numbers instead
          after = opts[:after]
          after = fields.find_index { |row| row[0].to_s.include?(after.to_s) }&.succ unless after.is_a?(Integer)
          content = ForemanColumnView::Columns.safe_value(self, host, name, cache)

          fields.insert(after&.clamp(0, fields.size) || -1, [ForemanColumnView::Columns.title(name), content])
        end

        fields
      end
    end

    included do
      prepend Overrides
    end
  end
end
