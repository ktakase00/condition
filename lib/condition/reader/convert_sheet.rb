# coding: utf-8
require 'json'
require 'roo'

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

      def convert_file(path, prefix: nil)
        name = File.basename(path, ".*")
        ss =  Roo::Spreadsheet.open(path)
        ss.sheets.each do |it|
          ss.default_sheet = it
          blocks = @reader.read(ss)
          key = "#{name}_#{it}"
          key = "#{prefix}_#{key}" if !prefix.nil?
          @redis.set(key, JSON.generate(blocks))
        end
      end

      def convert_dir(path, with_dir_name: true)
        basename = File.basename(path)
        Dir::entries(path).each do |f|
          next if "." == f || ".." == f || /^\.~lock\.[^.]+\.ods.$/ =~ f
          prefix = with_dir_name ? basename : nil
          convert_file("#{path}/#{f}", prefix: prefix)
        end
      end
    end
  end
end
