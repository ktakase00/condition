# coding: utf-8
require 'roo'

module Condition
  class Param
    def initialize(path, sheet_index=0)
      blocks = read_sheet(path, sheet_index)
      @item_map = {}
      blocks.each do |rows|
        item = Condition::ParamItem.new(rows)
        @item_map[item.name] = item
      end
    end

    def read_sheet(path, sheet_index)
      ss =  Roo::Spreadsheet.open(path)
      ss.default_sheet = ss.sheets[sheet_index]
      row_index = 1
      res = []
      while true
        break if nil == ss.cell(row_index, 1)
        table = []
        while true
          row = read_row(ss, row_index)
          row_index += 1
          break if 0 == row.size
          table << row
        end
        res << table
      end
      res
    end

    def read_row(ss, row_index)
      column_index = 1
      result = []
      while true
        value = ss.cell(row_index, column_index)
        return result if nil == value
        result << value
        column_index += 1
      end
    end

    def item(name)
      @item_map[name]
    end

    def get(name)
      item = @item_map[name]
      return nil if !item
      item.values
    end

    def get_one(name)
      item = @item_map[name]
      return nil if !item
      item.value
    end

    def check(name, data)
      item = @item_map[name]
      data.each do |line|
        item.check_line(line)
      end
    end

    def pre(db, default=nil)
      @item_map.each_value do |item|
        item.delete(db)
        item.insert(db, default)
      end
    end

    def post(db)
      @item_map.each_value do |item|
        list = item.all(db)
        list.each do |line|
          item.check_line(line)
        end
      end
    end
  end
end