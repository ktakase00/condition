module Condition
  module Storage
    class RailsDb
      LOG_NAME = 'SQL'

      def initialize(db, type: :postgresql)
        @conn = db.nil? ? ActiveRecord::Base.connection : db
        @type = type
      end

      def all(param_item)
        sql = "SELECT * FROM #{param_item.name}"
        res = exec(sql)
        convert_keys(res)
      end

      def delete(param_item)
        sql = "DELETE FROM #{param_item.name}"
        exec sql
      end

      def insert(param_item, default)
        default_item = default.item(param_item.name) if default
        prms = default_item ? default_item.params.merge(param_item.params) : param_item.params

        ph_ary = [] # array of placeholder
        num = 1

        prms.each do |k, v|
          ph_ary.push("$#{num}")
          num += 1
        end

        i1 = prms.keys.join(',')
        i2 = ph_ary.join(',')
        sql = "INSERT INTO #{param_item.name.to_s} (#{i1}) VALUES (#{i2})"

#        begin
#          cast_type = ActiveRecord::Type::Value.new
#        rescue => e
#          # Rails 4.1 だとActiveRecord::Typeクラスが見付からない
#          cast_type = nil
#        end

        param_item.values.each do |it|
          prms = default_item ? default_item.value.merge(it) : it

          insert_params = make_insert_params(prms)
          exec(sql, params: insert_params)
        end

      end

      def exec_after(param_item)
        param_item.options.each do |key|
          exec key
        end
      end

      private
        def exec(sql, params: [])
          @conn.exec_query(sql, LOG_NAME, params)
        end

        def convert_keys(ary)
          res = []
          ary.each do |row|
            res.push(row.deep_symbolize_keys)
          end
          res
        end

        def make_insert_params(prms)
          begin
            cast_type = ActiveRecord::Type::Value.new
          rescue => e
            # Rails 4.1 だとActiveRecord::Typeクラスが見付からない
            cast_type = nil
          end

          insert_params = []
          case @type
          when :postgresql
#            insert_params = make_insert_params_postgresql(prms, cast_type)
            generator = RailsDb::ParamsPostgresql.new
          else
            generator = RailsDb::ParamsDefault.new
          end
          insert_params = generator.make_insert_params(prms, cast_type)
        end

#        def make_insert_params_postgresql(prms, cast_type)
#          ary = []
#          prms.each_pair do |k, v|
#            key = k.to_s
#            col = ActiveRecord::ConnectionAdapters::PostgreSQLColumn.new(key, nil, cast_type)
#            matched = v.scan(/^\{(.*)\}$/) if !v.nil?

#            if matched.nil? || matched.empty?
#              val = v
#            else
#              val = matched[0][0].split(',')
#              col.array = true
#            end
#            ary.push([col, val])
#          end
#          ary
#        end
    end
  end
end
