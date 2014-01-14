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
        prms = default_item ? default_item.params.merge(param_item.params) : param_item.params
        i1 = ''
        i2 = ''
        prms.each_pair do |k, v|
          if i1 != ''
            i1 = i1 + ', '
            i2 = i2 + ', '
          end
          i1 = i1 + k.to_s
          i2 = i2 + '?'
        end
        sql = "INSERT INTO #{param_item.name.to_s} (#{i1}) VALUES (#{i2})"
        param_item.values.each do |it|
          prms = default_item ? default_item.value.merge(it) : it
          ary = [sql]
          prms.each_pair do |k, v|
            ary << v
          end
          @db.fetch(*ary).insert
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
