module RailsDb
  class ParamsDefault

    def make_insert_params(prms, cast_type)
          ary = []
          prms.each_pair do |k, v|
            col = ActiveRecord::ConnectionAdapters::Column.new(k.to_s,
              nil,
              cast_type)

            ary.push([col, v])
          end
          ary
    end

  end
end
