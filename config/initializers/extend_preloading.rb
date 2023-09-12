module ExtendedPreloading
  module RelationExtensions
    def select_includes(*args)
      @select_includes_values ||= {}
      # Parse arguments similar to `includes` method
      args.each do |arg|
        case arg
        when Hash
          arg.each do |key, value|
            @select_includes_values[key] = Array(value)
          end
        else
          @select_includes_values[arg] = []
        end
      end
      self
    end

    # Override the `exec_queries` method to perform our custom preloading before the original logic.
    def exec_queries(&block)
      unless @select_includes_values.blank?
        preload_with_select(@select_includes_values)
      end
      super(&block)
    end

    def preload_with_select(select_includes_values)
      select_includes_values.each do |association, fields|
        preload_scope = klass.reflect_on_association(association).klass.select(fields)
        ActiveRecord::Associations::Preloader.new(records: self, associations: association, scope: preload_scope)
      end
    end
  end
end

ActiveRecord::Relation.prepend(ExtendedPreloading::RelationExtensions)
