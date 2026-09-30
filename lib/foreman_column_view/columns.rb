module ForemanColumnView
  # Reads the :column_view section of the Foreman settings and turns it into
  # columns of the legacy hosts list and rows of the legacy host properties.
  module Columns
    DEFAULT_VIEW = :hosts_list
    DEFAULT_WIDTH = '10%'.freeze
    KEY_PREFIX = 'fcv_'.freeze
    CATEGORY_LABEL = 'Custom columns'.freeze


    module_function

    # { 'name' => { :title => ..., :content => ..., ... } }, sorted by name
    def all
      config = SETTINGS[:column_view]
      return {} unless config.respond_to?(:each_pair)

      config.each_pair.map { |name, opts| [name.to_s, (opts || {}).to_h.symbolize_keys] }.sort.to_h
    end

    def for_view(view)
      all.select { |_name, opts| (opts[:view] || DEFAULT_VIEW).to_sym == view }
    end

    def options(name)
      all[name.to_s] || {}
    end

    def key(name)
      "#{KEY_PREFIX}#{name}"
    end

    def title(name)
      options(name)[:title] || name.to_s.humanize
    end

    def visible?(host, name)
      conditional = options(name)[:conditional]
      return true if conditional.blank?

      method, *args = conditional.is_a?(Array) ? conditional : conditional.to_s.split
      host.respond_to?(method) && host.public_send(method, *args)
    rescue ArgumentError
      Rails.logger.warn("Foreman_column_view: You are supplying the wrong kind/number of arguments to your conditional method. Host #{host}, method - #{method} - arguments - #{args.join(', ')}")
      false
    end

    # Value of the column for the host, without any view context. Results of
    # the host methods are memoized in cache, so several columns reading the
    # same facts_hash only compute it once.
    def raw_value(host, name, cache = {})
      content = options(name)[:content].to_s
      if content =~ /\A(.*)\[(.*)\]\z/
        cache[Regexp.last_match(1)] ||= host.public_send(Regexp.last_match(1))
        cache[Regexp.last_match(1)]&.[](Regexp.last_match(2).delete(%q('")))
      else
        host.public_send(content)
      end
    end

    # Value to display, evaluated in the view context when :eval_content is set
    def value(view, host, name, cache = {})
      opts = options(name)
      return raw_value(host, name, cache) unless opts[:eval_content]

      # :content comes from the plugin settings file, which only the Foreman
      # administrator can write: evaluating it is the documented purpose of
      # :eval_content. It sees the host as `host` and the view helpers.
      code = opts[:content].to_s
      view.instance_exec(host) { |host| eval(code) } # rubocop:disable Security/Eval
    end

    def safe_value(view, host, name, cache = {})
      return unless visible?(host, name)
      value(view, host, name, cache)
    rescue StandardError => e
      Rails.logger.warn("Foreman_column_view: cannot compute column #{name} for host #{host}: #{e.class}: #{e.message}")
      nil
    end

    # Evaluated content needs a view context, so it is not exported to CSV
    def export_value(host, name)
      return if options(name)[:eval_content]
      safe_value(nil, host, name)
    end

    # Adds the header and content pagelets of the legacy hosts list
    def register_pagelets(context)
      existing = context.pagelets_at(:hosts_table_column_header)
      columns = for_view(:hosts_list).reject { |name, _| existing.any? { |pagelet| pagelet.opts[:key].to_s == key(name) } }
      return if columns.empty?

      column_priorities = priorities(columns,
        existing.map { |pagelet| { key: pagelet.opts[:key].to_s, label: pagelet.opts[:label].to_s, priority: pagelet.priority } })

      context.with_profile :column_view, CATEGORY_LABEL, default: true do
        columns.each do |name, opts|
          header = {
            key: ForemanColumnView::Columns.key(name),
            label: ForemanColumnView::Columns.title(name),
            sortable: false,
            width: opts[:width] || DEFAULT_WIDTH,
            class: 'hidden-tablet hidden-xs',
            priority: column_priorities[name],
          }
          if defined?(::CsvExporter::ExportDefinition)
            header[:export_data] = ::CsvExporter::ExportDefinition.new(header[:key], label: header[:label],
              callback: ->(host) { ForemanColumnView::Columns.export_value(host, name) })
          end
          add_pagelet :hosts_table_column_header, header
          add_pagelet :hosts_table_column_content,
            key: header[:key],
            class: 'hidden-tablet hidden-xs ellipsis',
            priority: column_priorities[name],
            callback: ->(host) { ForemanColumnView::Columns.safe_value(self, host, name) }
        end
      end
    end

    # Computes the pagelet priority of each column so that it lands right
    # after the column named by :after, unless :priority is given. Existing
    # columns are given as [{ key:, label:, priority: }]. Columns can refer to
    # each other, in any order; unresolved ones are appended at the end.
    def priorities(columns, existing, gap: 100)
      taken = existing.map { |col| col.merge(names: [col[:key], col[:label]].compact.map { |n| n.to_s.downcase }) }
      result = {}
      pending = columns.to_a

      place = lambda do |name, position|
        result[name] = position
        taken << { names: [name.downcase, key(name).downcase], priority: position }
      end

      loop do
        progress = false
        pending = pending.reject do |name, opts|
          if opts[:priority].is_a?(Numeric)
            place.call(name, opts[:priority])
            next progress = true
          end
          anchor = taken.find { |col| col[:names].include?(opts[:after].to_s.downcase) }
          next false unless anchor

          following = taken.map { |col| col[:priority] }.select { |priority| priority > anchor[:priority] }.min
          place.call(name, following ? (anchor[:priority] + following) / 2.0 : anchor[:priority] + gap)
          progress = true
        end
        break if pending.empty? || !progress
      end

      pending.each do |name, _opts|
        place.call(name, (taken.map { |col| col[:priority] }.max || 0) + gap)
      end
      result
    end
  end
end
