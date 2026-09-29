$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "foreman_column_view/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name = %q{foreman_column_view}
  s.version     = ForemanColumnView::VERSION
  s.authors = ["Greg Sutcliffe"]
  s.email = "greg.sutcliffe@gmail.com"
  s.description = "Displays additional columns in the Foreman hosts list
  and/or additional entries in the host details page"
  s.extra_rdoc_files = [
    "LICENSE",
    "README.md"
  ]
  s.files = Dir["{app,extra,config,db,lib,webpack}/**/*", "public/webpack/**/*"] + ["LICENSE", "Rakefile", "README.md", "package.json"]
  s.test_files = Dir["test/**/*"]
  s.homepage = "https://github.com/theforeman/foreman_column_view"
  s.license = "GPL-3.0"
  s.summary = "Column View Plugin for Foreman"

  s.required_ruby_version = ">= 2.7", "< 4"
end

