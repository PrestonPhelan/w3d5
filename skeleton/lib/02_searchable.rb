require_relative 'db_connection'
require_relative '01_sql_object'
require_relative 'relation'

module Searchable
  def where(params)
    Relation.new(self, params)
  end
end

class SQLObject
  # Mixin Searchable here...
  extend Searchable
end
