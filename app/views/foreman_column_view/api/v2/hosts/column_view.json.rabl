node :column_view do |host|
  ForemanColumnView::Columns.api_values((respond_to?(:context_scope) && context_scope) || self, host)
end
