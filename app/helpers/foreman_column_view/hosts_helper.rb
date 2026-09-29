module ForemanColumnView
  # Kept for configurations whose :eval_content calls these helpers
  module HostsHelper
    def fcv_title(column)
      ForemanColumnView::Columns.title(column)
    end

    def fcv_content(host, column)
      ForemanColumnView::Columns.raw_value(host, column)
    end
  end
end
