module Condition
  class Table
    def initialize(rows)
      @table_name = rows[0][0]
      @keys = rows[0].size > 1 ? rows[0][1..rows.size - 1] : []
      body = rows[1..rows.size - 1]
      @values = []
      @params = {}
      body.each do |row|
        index = 0
        name = row[0]
        @params[name.to_sym] = ("$" + name).to_sym
        items = row[1..row.size - 1]
        value = nil
        items.each do |item|
          value = @values[index] ? @values[index] : {}
          value[name.to_sym] = '#NULL' == item ? nil : item
          @values[index] = value
          index += 1
        end
      end
    end

    def all(db)
      db["SELECT * FROM #{@table_name}"].all
    end

    def delete(db)
      db["DELETE FROM #{@table_name}"].delete
    end

    def insert(db)
      ds = db[@table_name.to_sym].prepare(:insert, :insert_with_name, @params)
      @values.each do |it|
        ds.call(it)
      end
    end

    def value_match?(expected, real)
      if Time === real
        real == Time.parse(expected)
      elsif nil == real
        expected == nil
      else
        real.to_s == expected
      end
    end

    def check_value(real, value)
      targetFlag = true
      matchFlag = true
      value.each_pair do |k, v|
        match = value_match?(v, real[k])
        whereKeyFlag = nil != @keys.index(k.to_s)
        matchFlag = false if !match
        targetFlag = false if whereKeyFlag && !match
      end
      if targetFlag && matchFlag
        return true
      elsif !targetFlag
        return false
      else
        raise "#{@table_name} not match " + real.to_s
      end
    end

    def check_line(real)
      @values.each do |value|
        return if check_value(real, value)
      end
      raise "#{@table_name} not found " + real.to_s
    end

  end
end