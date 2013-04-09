# coding: utf-8

module Condition
  class Post
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
        list = table.all(db)
        list.each do |line|
          table.check_line(line)
        end
      end
    end
  end
end