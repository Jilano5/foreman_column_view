# foreman\_column\_view

A small plugin that adds columns, configured in a settings file, to the hosts
list, and rows to the host properties.

Foreman 3.5 added a column selector to the hosts list, but no way to define
your own columns: this plugin adds them.

With Foreman 3.19 the plugin works on the legacy pages only:

* the legacy hosts list (`/hosts`): the columns are listed in the "Custom
  columns" group of the column selector, shown by default, and included in the
  CSV export (except columns using `:eval_content`);
* the legacy host page: rows configured with `:view: :hosts_properties` are
  added to the Properties table.

Foreman 3.19 shows the new React pages by default. To use the legacy ones, set
*Show New Host Overview Page* (`new_hosts_page`) and *New host details UI*
(`host_details_ui`) to *No* in Administer > Settings > General.

## Compatibility

| Foreman Version | Plugin Version |
| --------------- | --------------:|
| <= 1.15         | ~> 0.3         |
| == 1.16         | untested       |
| >= 1.17, < 3.5  | ~> 0.4         |
| >= 3.19         | ~> 1.0         |

# Installation

The plugin is not published on rubygems.org: build the gem from this
repository (it only needs Ruby, not Foreman):

    gem build foreman_column_view.gemspec

On a Debian package based install, copy `foreman_column_view-<version>.gem` to
`/usr/share/foreman/vendor/cache/`, then declare it in
`/usr/share/foreman/bundler.d/Gemfile.local.rb`:

```ruby
gem 'foreman_column_view', '1.0.0'
```

and install it as the foreman user:

    cd /usr/share/foreman
    runuser -u foreman -- env HOME=/usr/share/foreman bundle install --local

Restart Foreman after the installation and after every configuration change.

# Configuration

By default the plugin will display the Domain associated by each host. This is not
massively useful. To set your own choice of column, add this to Foreman's plugin config file
`foreman_column_view.yaml`. For package based installs this should be in
`/etc/foreman/plugins/foreman_column_view.yaml`. For source installs this should be in
`config/settings.plugins.d` within your install directory.

```yaml
:column_view:
  :name1:
    :title: Shortname1
    :after: last_report
    :content: shortname1
  :name2:
    :title: Shortname2
    :after: name1
    :content: facts_hash['shortname2']
```

`title` is an arbitrary string which is displayed as the column header. `content` is
a method call to the `Host` object, using `host.public_send`. In these examples `facts_hash`
and `params` are method calls to `Host` returning hash values.

`after` is the key of the column after which the new one is placed: a core column
(`power_status`, `name`, `os_title`, `owner`, `hostgroup`, `organization`, `location`,
`boot_time`, `last_report`, `comment`, `ip`, `ip6`, `mac`, `model`, ...) or another
column of this plugin (`name1` above). Columns with an unknown `after` are added at
the end. The position can also be given explicitly with `:priority` (core columns
use 100, 200, ...).

The column selector refers to the columns as `fcv_<name>` (`fcv_name1` above). Users
who already saved a column selection must select the new columns there to see them.

```yaml
:column_view:
  :architecture:
    :title: Architecture
    :after: last_report
    :content: facts_hash['architecture']
  :uptime:
    :title: Uptime
    :after: architecture
    :content: facts_hash['uptime']
  :color:
    :title: Color
    :after: last_report
    :content: params['favorite_color']

```

Additional rows can also be added to the Properties table on the host page by setting
`:view: :hosts_properties`.  The position is also controlled by `:after` using either a
numeric index to represent the row or the name of the previous row (however this will
not work well when the Foreman language is switched).  An example configuration:

```yaml
:column_view:
  :uptime:
    :title: Uptime
    :after: 6
    :content: facts_hash['uptime']
    :view: :hosts_properties
```

You can also control the width of the added column by giving a value to the `:width`
attribute. If the width is not set, the default is set to 10%. Note that the original
host list already has 100% width set, so adding more columns will cause other columns
to resize, which may cause some of the table layout to break a bit. For example:

```yaml
:column_view:
  :domain:
    :title: Domain
    :after: model
    :content: domain
    :width: 7%
```

If you need to add information not readily available in a host, you can add information that
will be evaluated on runtime by adding `:eval_content: true` to your additional row or column.
The code sees the host as `host` and can use the Rails view helpers; its result is
HTML-escaped unless it is marked safe (as `link_to` results are).
Also, some times you do not want to show the additional row if a certain condition is not met,
in order to show that row conditionally, add `:conditional: :condition_symbol` to your configuration,
and that conditional will be executed on your host. Columns of the hosts list are left empty
when the condition is not met.

As an example, the following yaml shows a link to a custom URL if the method host.bmc_available? is true.

```yaml
  :console:
    :title: Console
    :after: 0
    :content: link_to(_("Console"), "https://#{host.interfaces.first.name}.domainname", { :class => "btn btn-info" } )
    :conditional: :bmc_available?
    :eval_content: true
    :view: :hosts_properties
```

If your conditional method needs arguments to work, the arguments should go after the method name separated by
spaces, as in `:custom_method arg1 arg2`


You will need to restart Foreman for changes to take effect, as the `settings.yaml` is
only read at startup.

# TODO

* Add plugin settings to the Settings UI
* Make the column sortable
* Support adding data to other pages
* Translate the column titles

# Copyright

Copyright (c) 2013 Greg Sutcliffe

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <http://www.gnu.org/licenses/>.
