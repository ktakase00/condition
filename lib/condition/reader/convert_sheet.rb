# coding: utf-8
require 'json'

module Condition
  module Reader
    class ConvertSheet
      def initialize(redis)
        @redis = redis
        @reader = Condition::Reader::RooReader.new
      end

      def convert(path, sheet_index, name)
        @redis.set(name, JSON.generate(@reader.read_sheet(path, sheet_index)))
      end
    end
  end
end
