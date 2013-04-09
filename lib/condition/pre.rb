module Condition
  class Pre
    include Condition::Reader;

    def initialize(path, sheet_index=0)
      @tables = read_sheet(path, sheet_index)
    end

    def exec(db)
      @tables.each do |table|
        table_name = table[0][0]
        ds = db["DELETE FROM #{table_name}"]
        ds.delete
        table.shift
        exec_insert(db, table_name, table)
      end
    end

    def exec_insert(db, table_name, lines)
      params = {}
      values = []
      
      lines.each do |it|
        params[it[0].to_sym] = "$#{it[0]}".to_sym
        name = "#{it[0]}".to_sym
        it.shift
        index = 0
        it.each do |item|
          value = values[index] ? values[index] : {}
          value[name] = '#NULL' == item ? nil : item
          values[index] = value
          index += 1
        end
      end

      ds = db[table_name.to_sym].prepare(:insert, :insert_with_name, params)
      values.each do |it|
        ds.call(it)
      end
    end
  end
end