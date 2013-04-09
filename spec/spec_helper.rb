require 'bundler/setup'
require 'condition'
require 'sequel'

FILES = File.dirname(__FILE__) + "/files"
DB = Sequel.connect('postgres://localhost:5432/test?user=aoyagikouhei')

RSpec.configure do |config|
  # some (optional) config here
end
