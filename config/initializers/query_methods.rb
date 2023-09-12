module QueryMethod
  def select(*fields)
    super
    fields = process_select_args(fields)
    spawn._select!(*fields)
  end

  def process_select_args(fields)
    fields.flat_map do |field|
      if field.is_a?(Hash)
        transform_select_hash_values(field)
      else
        field
      end
    end
  end

  def transform_select_hash_values(fields)
    fields.flat_map do |key, columns_aliases|
      case columns_aliases
      when Hash
        columns_aliases.map do |column, column_alias|
          arel_column("#{key}.#{column}") do
            predicate_builder.resolve_arel_attribute(key.to_s, column)
          end.as(column_alias.to_s)
        end
      when Array
        columns_aliases.map do |column|
          arel_column("#{key}.#{column}", &:itself)
        end
      when String, Symbol
        arel_column(key.to_s) do
          predicate_builder.resolve_arel_attribute(klass.table_name, key.to_s)
        end.as(columns_aliases.to_s)
      end
    end
  end
end

ActiveRecord::Relation.prepend(QueryMethod)
