# coding: utf-8
require 'time'
require 'json'
require 'active_support/all'

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
        expected == nil || expected == "#NULL"
      elsif Hash === real
        ex = expected
        if !(Hash === expected)
          ex = JSON.parse(expected)
        end
        ex = ex.symbolize_keys
        result = true
        ex.each_pair do |k, v|
          res = value_match?(v, real[k])
          result = false if !res
        end
        result
      elsif Array === real
        ex = expected
        if !(Array === expected)
          ex = JSON.parse(expected)
        end
        false if Array === ex
        size = ex.size()
        true if size == 0 && real.size() == 0
        false if size != real.size()
        index = 0
        while true
          break if index >= size
          result = value_match?(ex[index], real[index])
          return false if !result
          index = index + 1
        end
        true
      else
        real.to_s == expected
      end
    end

    def check_value(real, value)
      targetFlag = true
      matchFlag = true
      unmatch_info = []
      real = real.symbolize_keys
      value.each_pair do |k, v|
        match = value_match?(v, real[k])
        unmatch_info << v.to_s + " <> " + real[k].to_s if !match
        whereKeyFlag = nil != @keys.index(k.to_s)
        matchFlag = false if !match
        targetFlag = false if whereKeyFlag && !match
      end
      if targetFlag && matchFlag
        return true
      elsif !targetFlag
        return false
      else
        raise "#{@name} not match " + real.to_s + "\n" + unmatch_info.join("\n")
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