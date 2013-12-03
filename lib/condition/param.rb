# coding: utf-8

module Condition
  class Param
    def self.set_reader(reader)
      @@reader = reader
    end
    
    def self.get_reader()
      if @@reader.nil?
        @@reader = Condition::Reader::RooReader.new
      end
      @@reader
    end

    def initialize(path, sheet_index=0)
      blocks = Condition::Param.get_reader().read_sheet(path, sheet_index)
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
