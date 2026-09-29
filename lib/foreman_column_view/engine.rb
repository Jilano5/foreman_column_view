require 'foreman_column_view/columns'

module ForemanColumnView
  class Engine < ::Rails::Engine
    engine_name 'foreman_column_view'

    initializer 'foreman_column_view.register_plugin', :before => :finisher_hook do |app|
      app.reloader.to_prepare do
        Foreman::Plugin.register :foreman_column_view do
          requires_foreman '>= 3.19'

          # Columns of the React hosts index page and host details card
          register_global_js_file 'global'
          extend_rabl_template 'api/v2/hosts/main', 'foreman_column_view/api/v2/hosts/column_view'

          # Columns of the legacy hosts index page
          extend_page('hosts/_list') { |context| ForemanColumnView::Columns.register_pagelets(context) }
        end

        if ::Foreman::Plugin.respond_to?(:app_metadata_registry)
          ::Foreman::Plugin.app_metadata_registry.register(:foreman_column_view, columns: ForemanColumnView::Columns.metadata)
        end
      end
    end

    config.to_prepare do
      # Extend core HostsHelper to add rows to Properties on the legacy hosts/show
      ::HostsHelper.include ForemanColumnView::HostsHelper
      ::HostsHelper.include ForemanColumnView::HostsHelperExtension
    rescue StandardError => e
      Rails.logger.warn "ForemanColumnView: skipping engine hook (#{e})"
    end
  end
end
