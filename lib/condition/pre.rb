# coding: utf-8

module Condition
  class Pre
    include Condition::Reader;

    def initialize(path, sheet_index=0)
      tables = read_sheet(path, sheet_index)
      @tables = []
      tables.each do |rows|
        @tables << Condition::Table.new(rows)
      end
    end

    def exec(db)
      @tables.each do |table|
        table.delete(db)
        table.insert(db)
      end
    end
    
  end
end