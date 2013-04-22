# coding: utf-8

module Condition
  module Storage
    class Db
      def initialize(db)
        @db = db
      end

      def all(param_item)
        @db["SELECT * FROM #{param_item.name}"].all
      end

      def delete(param_item)
        @db["DELETE FROM #{param_item.name}"].delete
      end

      def insert(param_item, default)
        default_item = default.item(param_item.name) if default
        ds = @db[param_item.name.to_sym].prepare(
          :insert, 
          :insert_with_name, 
          default_item ? default_item.params.merge(param_item.params) : param_item.params)
        param_item.values.each do |it|
          ds.call(default_item ? default_item.value.merge(it) : it)
        end
      end

      def exec_after(param_item)
        param_item.options.each do |key|
          @db.run key
        end
      end
    end
  end
end