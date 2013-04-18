# coding: utf-8
require 'time'
require 'json'

module Condition
  class ParamItem
    def initialize(rows)
      @name = rows[0][0].to_sym
      @options = rows[0].size > 1 ? rows[0][1..rows.size - 1] : []
      body = rows[1..rows.size - 1]
      @values = []
      @keys = []
      @params = {}
      @refs = []
      body.each do |row|
        index = 0
        key = row[0].to_sym
        @keys = key
        @params[key] = ("$" + key.to_s).to_sym
        items = row[1..row.size - 1]
        value = nil
        items.each do |item|
          value = @values[index] ? @values[index] : {}
          value[key] = calc_item(item, index, key)
          @values[index] = value
          index += 1
        end
      end
    end

    def calc_item(item, index, key)
      if '#NULL' == item
        nil
      elsif '#EMPTY' == item
        []
      elsif /^#REF\((.+)\)$/ =~ item
        ary = $1.split(/,/)
        count = ary.size > 1 ? ary[1].strip.to_i : nil
        @refs << {index: index, key: key, name: ary[0].strip.to_sym, count: count}
        item
      elsif /^#JSON\((.+)\)$/ =~ item
        JSON.parse($1, {:symbolize_names => true})
      else
        item
      end
    end

    def apply_ref(param)
      @refs.each do |it|
        @values[it[:index]][it[:key]] = param.get(it[:name], it[:count])
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
      @options.each do |key|
        db.run key
      end
    end

    def value_match?(expected, real)
      if Time === real
        real == Time.parse(expected)
      elsif nil == real
        expected == nil
      elsif Hash === real
        if !(Hash === expected)
          false
        elsif real == expected
          true
        else
          result = true
          expected.each_pair do |k, v|
            res = value_match?(v, real[k])
            result = false if !res
          end
          result
        end
      elsif Array === real
        if !(Array === expected)
          false
        elsif real.size() == 0 && expected.size() == 0
          true
        elsif real == expected
          true
        else
          index = 0
          result = true
          while true
            break if index >= expected.size
            res = value_match?(expected[index], real[index])
            if !res
              result = false
              break
            end
            index += 1
          end
          result
        end
      else
        real.to_s == expected
      end
    end

    def check_value(real, value)
      targetFlag = true
      matchFlag = true
      unmatch_info = []
      value.each_pair do |k, v|
        match = value_match?(v, real[k])
        unmatch_info << v.to_s + " <> " + real[k].to_s if !match
        whereKeyFlag = nil != @options.index(k.to_s)
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