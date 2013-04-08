require 'roo'
require 'sequel'

module Condition
  class Pre
    def initialize(dbInfo, path, sheet_index=0)
      @db = Sequel.connect(dbInfo)
      @path = path
      @ss =  Roo::Spreadsheet.open(path)
      @ss.default_sheet = @ss.sheets[sheet_index]
    end

    def exec
      row_index = 1
      while true
        row_index = exec_table(row_index)
        break if nil == row_index
      end
    end

    def exec_table(row_index)
      table_name = @ss.cell(row_index, 1)
      return nil if nil == table_name
      ds = @db["DELETE FROM #{table_name}"]
      ds.delete

      lines = []
      while true
        row_index += 1
        line = readRow(row_index)
        break if line.empty?
        lines << line
      end
      exec_insert(table_name, lines)
      return row_index + 1
    end

    def exec_insert(table_name, lines)
      params = {}
      values = []
      lines.each do |it|
        name = "$#{it[0]}".to_sym
        params[it[0].to_sym] = name
        value = {}
        it.shift
        it.each do |val|
          
        end
        values << value
      end
      ds = @db[table_name.to_sym].prepare(:insert, :insert_with_name, params)


    end

    def readRow(row_index)
      column_index = 1
      result = []
      while true
        value = @ss.cell(row_index, column_index)
        return result if nil == value
        result << value
        column_index += 1
      end
    end
  end
end