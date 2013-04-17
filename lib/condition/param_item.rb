# coding: utf-8
require 'time'

module Condition
  class ParamItem
    def initialize(rows)
      @name = rows[0][0]
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

    def name
      @name
    end

    def value
      @values[0]
    end

    def values
      @values
    end

    def params
      @params
    end

    def all(db)
      db["SELECT * FROM #{@name}"].all
    end

    def delete(db)
      db["DELETE FROM #{@name}"].delete
    end

    def insert(db, default)
      item = default.item(@name) if default
      ds = db[@name.to_sym].prepare(
        :insert, 
        :insert_with_name, 
        item ? item.params.merge(@params) : @params)
      @values.each do |it|
        ds.call(item ? item.value.merge(it) : it)
      end
    end

    def exec_after(db)
      @keys.each do |key|
        db.run key
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
        match = value_match?(v, nil == real[k] ? real[k.to_s] : real[k])
        whereKeyFlag = nil != @keys.index(k.to_s)
        matchFlag = false if !match
        targetFlag = false if whereKeyFlag && !match
      end
      if targetFlag && matchFlag
        return true
      elsif !targetFlag
        return false
      else
        raise "#{@name} not match " + real.to_s
      end
    end

    def check_line(real)
      @values.each do |value|
        return if check_value(real, value)
      end
      raise "#{@name} not found " + real.to_s
    end

  end
end