module ExtendedPreloader
  module AssociationExtensions
    def run
      # The 'run' method is what executes the preload. We'll wrap it and modify the loaded records before it returns.
      super
      constrain_fields if select_constraints.present?
    end

    # This will hold our custom select constraints
    def select_constraints
      @select_constraints ||= {}
    end

    # Apply constraints to the loaded records. This is a simple version and can be extended.
    def constrain_fields
      if select_constraints.key?(reflection.name)
        fields = select_constraints[reflection.name]
        records.each do |record|
          (record.attributes.keys - fields).each do |key_to_remove|
            record[key_to_remove] = nil
          end
        end
      end
    end
  end

  def initialize(records:, associations:, scope: nil, available_records: [], associate_by_default: true, select_constraints: {})
    super(records: records, associations: associations, scope: scope, available_records: available_records, associate_by_default: associate_by_default)
    @select_constraints = select_constraints
  end

  # Add our custom select constraints to the individual Association preloader
  def preloader_for(reflection, records, preload_scope)
    if @select_constraints[reflection.name]
      preload_scope = reflection.klass.select(@select_constraints[reflection.name])
    end

    preloader = super
    preloader.singleton_class.prepend(AssociationExtensions)
    preloader.select_constraints.merge!(@select_constraints)
    preloader
  end
end

ActiveRecord::Associations::Preloader.prepend(ExtendedPreloader)
