require_relative '03_associatable'

# Phase IV
module Associatable
  # Remember to go back to 04_associatable to write ::assoc_options

  def has_one_through(name, through_name, source_name)
    through_options = assoc_options[through_name]

    define_method(name) do
      source_options = through_options.model_class.assoc_options[source_name]
      
      through_class = through_options.model_class
      through_fk_value = send(through_options.foreign_key)
      through_pk_column = through_options.primary_key.to_sym

      through_result = through_class
        .where(through_pk_column => through_fk_value).first


      source_class = source_options.model_class
      source_fk_value = through_result.send(source_options.foreign_key)
      source_pk_column = source_options.primary_key.to_sym

      source_class.where(source_pk_column => source_fk_value).first


      #self.send(through_name).send(source_name)
    end


  end
end
