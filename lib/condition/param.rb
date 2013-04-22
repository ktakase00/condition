# coding: utf-8
require 'roo'

module Condition
  class Param
    def initialize(path, sheet_index=0)
      blocks = read_sheet(path, sheet_index)
      @item_map = {}
      item_list = []
      blocks.each do |rows|
        item = Condition::ParamItem.new(rows)
        @item_map[item.name] = item
        item_list << item
      end
      item_list.reverse.each do |it|
        it.apply_ref(self)
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
      @item_map[name.to_sym]
    end

    def get(name, index=nil)
      item = item(name)
      return nil if !item
      return item.values if !index
      return item.values[index]
    end

    def check(name, data)
      item = item(name)
      data.each do |line|
        item.check_line(line)
      end
    end

    def pre(storage, default=nil)
      @item_map.each_value do |item|
        storage.delete(item)
        storage.insert(item, default)
        storage.exec_after(item)
      end
    end

    def post(storage)
      @item_map.each_value do |item|
        list = storage.all(item)
        list.each do |line|
          item.check_line(line)
        end
      end
    end
  end
end