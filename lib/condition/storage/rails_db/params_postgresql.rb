module Condition
  module Storage
    module RailsDb

      class ParamsPostgresql

        def make_insert_params(prms, cast_type)
          ary = []
          prms.each_pair do |k, v|
            key = k.to_s
            col = ActiveRecord::ConnectionAdapters::PostgreSQLColumn.new(key,
              nil,
              cast_type)

            matched = v.scan(/^\{(.*)\}$/) if !v.nil?

            if matched.nil? || matched.empty?
              val = v
            else
              val = matched[0][0].split(',')
              col.array = true
            end
            ary.push([col, val])
          end
          ary
        end

      end

    end
  end
end
