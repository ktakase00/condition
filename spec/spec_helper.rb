# coding: utf-8

require 'bundler/setup'
require 'condition'
require 'sequel'
require 'pg'
require 'mongo'
require 'condition/storage/db'
require 'condition/storage/mongo'

FILES = File.dirname(__FILE__) + "/files"
DB = Sequel.connect('postgres://localhost:5432/test?user=aoyagikouhei')
MONGO = Mongo::MongoClient.new('localhost', 27017)['test']

RSpec.configure do |config|
  # some (optional) config here
end
