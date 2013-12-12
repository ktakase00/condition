# coding: utf-8
require 'json'

module Condition
  module Reader
    class RedisReader
      def initialize(redis)
        @redis = redis 
      end

      def read_sheet(path, sheet_index)
        data = @redis.get(path)
        raise "redis key name #{path} not found" if data.nil? || data == ""
        JSON.parse(data, {:symbolize_names => true})
      end
    end
  end
end
