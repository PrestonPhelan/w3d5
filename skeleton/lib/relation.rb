require_relative 'db_connection'

class Relation
  attr_reader :options

  def method_missing(method_name, *args)
    # super if respond_to_missing?
    execute_search.send(method_name, *args)
    #
    # results.send(method_name)
  end

  def initialize(model_class, params)
    @model_class = model_class
    @options = params
  end

  def execute_search
    where_line = options.keys.map { |key| "#{key} = ?" }.join(" AND ")

    result = DBConnection.execute(<<-SQL, options.values)
      SELECT *
      FROM #{@model_class.table_name}
      WHERE
        #{where_line}
    SQL

    @model_class.parse_all(result)
  end
  #
  # def first
  #   execute_search.first
  # end
  #
  # def length
  #   execute_search.length
  # end
end
