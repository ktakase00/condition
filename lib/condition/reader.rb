require 'roo'

module Condition
  module Reader
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
  end
end