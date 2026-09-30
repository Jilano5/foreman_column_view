require 'foreman_column_view/columns'

module ForemanColumnView
  class Engine < ::Rails::Engine
    engine_name 'foreman_column_view'

    initializer 'foreman_column_view.register_plugin', :before => :finisher_hook do |app|
      app.reloader.to_prepare do
        Foreman::Plugin.register :foreman_column_view do
          requires_foreman '>= 3.19'

          # Columns of the legacy hosts index page
          extend_page('hosts/_list') { |context| ForemanColumnView::Columns.register_pagelets(context) }
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
