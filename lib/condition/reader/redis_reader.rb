# coding: utf-8
require 'json'

module Condition
  module Reader
    class RedisReader
      def initialize(redis)
        @redis = redis 
      end

      def read_sheet(path, sheet_index)
        JSON.parse(@redis.get(path), {:symbolize_names => true})
      end
    end
  end
end
