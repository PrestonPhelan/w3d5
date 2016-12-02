require_relative 'db_connection'
require 'active_support/inflector'
# NB: the attr_accessor we wrote in phase 0 is NOT used in the rest
# of this project. It was only a warm up.

class SQLObject
  def self.columns
    return @columns if @columns
    data = DBConnection.execute2(<<-SQL)
      SELECT *
      FROM #{table_name}
      LIMIT 1
    SQL

    @columns = data.first.map(&:to_sym)
  end

  def self.finalize!
    columns.each do |column|
      define_method(column) { attributes[column] }
      define_method("#{column}=") do |value|
        attributes[column] = value
      end
    end
  end

  def self.table_name=(table_name)
    @table_name = table_name
  end

  def self.table_name
    @table_name || self.name.tableize
  end

  def self.all
    results = DBConnection.execute(<<-SQL)
      SELECT *
      FROM #{table_name}
    SQL

    parse_all(results)
  end

  def self.parse_all(results)
    objects = []
    results.each do |result|
      objects << self.new(result)
    end

    objects
  end

  def self.find(id)
    result = DBConnection.execute(<<-SQL, id)
      SELECT *
      FROM #{table_name}
      WHERE id = ?
    SQL

    parse_all(result).first
  end

  def initialize(params = {})
    self.class.finalize!

    params.each do |attr_name, value|
      column_name = attr_name.to_sym
      unless self.class.columns.include?(column_name)
        raise "unknown attribute '#{attr_name}'"
      end

      send("#{column_name}=", value)
    end
  end

  def attributes
    @attributes ||= {}
  end

  def attribute_values

    self.class.columns.map do |column|
      send(column)
    end
  end

  def insert
    col_names = self.class.columns.join(", ")
    question_marks = (["?"] * self.class.columns.length).join(", ")

    DBConnection.execute(<<-SQL, attribute_values)
      INSERT INTO
        #{self.class.table_name} (#{col_names})
      VALUES
        (#{question_marks})
    SQL

    self.id = DBConnection.last_insert_row_id
  end

  def update
    updates = self.class.columns.map do |attr_name|
      "#{attr_name} = ?"
    end

    update_string = updates.join(", ")
    DBConnection.execute(<<-SQL, attribute_values, id)
      UPDATE
        #{self.class.table_name}
      SET
        #{update_string}
      WHERE
        id = ?
    SQL
  end

  def save
    if id
      update
    else
      insert
    end
  end
end
