# coding: utf-8
module Condition
  class Param
    @@reader = nil

    def self.set_reader(reader)
      @@reader = reader
    end
    
    def self.get_reader()
      if @@reader.nil?
        @@reader = Condition::Reader::RooReader.new
      end
      @@reader
    end

    def initialize(path, sheet_index=0, blks: nil, reader: nil)
      if blks.nil?
        rd = reader.nil? ? Condition::Param.get_reader() : reader
        blocks = rd.read_sheet(path, sheet_index)
        set_blocks(blocks)
      else
        set_blocks(blks)
      end
    end

    def set_blocks(blocks)
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
        item.clear_used_values
        list = storage.all(item)
        list.each do |line|
          item.check_line(line)
        end
        raise "#{item.name} not exists row" if item.is_remain_value
      end
    end
  end
end
