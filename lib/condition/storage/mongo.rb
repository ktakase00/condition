# coding: utf-8

module Condition
  module Storage
    class Mongo
      def initialize(db)
        @db = db
      end

      def all(param_item)
        @db[param_item.name].find()
      end

      def delete(param_item)
        @db[param_item.name].remove()
      end

      def insert(param_item, default)
        default_item = default.item(param_item.name) if default
        param_item.values.each do |it|
          @db[param_item.name].insert(default_item ? default_item.value.merge(it) : it)
        end
      end

      def exec_after(param_item)
        param_item.options.each do |key|
          # nothing
        end
      end
    end
  end
end