$LOAD_PATH.unshift File.expand_path('../..', __FILE__)

require 'rspec'

RSpec.configure do |config|
  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  config.order = 'random'
end
