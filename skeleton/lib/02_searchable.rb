require_relative 'db_connection'
require_relative '01_sql_object'
require_relative 'relation'

module Searchable
  def where(params)
    conditions = params

    if self.is_a?(Relation)
      options.each do |k, v|
        conditions[k] ||= v
      end
      model_class = self.model_class
    else
      model_class = self
    end

    Relation.new(model_class, params)
  end
end

class SQLObject
  # Mixin Searchable here...
  extend Searchable
end
