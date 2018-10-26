require 'rspec'
require 'simplecov'

SimpleCov.start do
  coverage_dir 'spec/coverage'
  add_filter 'spec'
  add_filter '.bundle'
end

require 'html2confluence'

RSpec.configure do |config|
  config.filter_gems_from_backtrace "rspec-core", "rspec"
  config.run_all_when_everything_filtered = true
  config.order = :random
end

