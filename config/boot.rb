require "bundler/setup"
require "dotenv/load"
require "json"

Dir["./lib/**/*.rb"].sort.each { |f| require f }
Dir["./consumers/**/*.rb"].sort.each { |f| require f }
