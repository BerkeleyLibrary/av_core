require 'simplecov-rcov'

SimpleCov.start 'rails' do
  add_filter 'module_info.rb'
  coverage_dir 'spec/reports'
  formatter SimpleCov::Formatter::RcovFormatter
  minimum_coverage 100
end
