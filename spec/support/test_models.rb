module VCAP::CloudController
  class TestModelDestroyDep < Sequel::Model; end
  class TestModelNullifyDep < Sequel::Model; end
  class TestModelManyToOne < Sequel::Model
    many_to_one :test_model
    export_attributes :test_model_guid
  end
  class TestModelManyToMany < Sequel::Model
    one_to_many :test_model_second_levels
  end
  class TestModelSecondLevel < Sequel::Model
    many_to_one :test_model_many_to_many
  end

  class TestModel < Sequel::Model
    one_to_many :test_model_destroy_deps
    one_to_many :test_model_nullify_deps
    one_to_many :test_model_many_to_ones
    many_to_many :test_model_many_to_manies, join_table: :test_model_m_to_m_test_models

    add_association_dependencies(:test_model_destroy_deps => :destroy,
                                 :test_model_nullify_deps => :nullify)

    import_attributes :required_attr, :unique_value, :test_model_many_to_many_guids
    export_attributes :unique_value

    def validate
      validates_unique :unique_value
    end
  end

  class TestModelAccess < BaseAccess; end
  class TestModelDestroyDepAccess < BaseAccess; end
  class TestModelNullifyDepAccess < BaseAccess; end
  class TestModelManyToOneAccess < BaseAccess; end

  class TestModelsController < RestController::ModelController
    define_attributes do
      attribute :required_attr, TrueClass
      attribute :unique_value, String
      to_many :test_model_many_to_ones
      to_many :test_model_many_to_manies
      to_many :test_model_many_to_manies_link_only, association_name: :test_model_many_to_manies, link_only: true
    end

    query_parameters :unique_value, :created_at

    define_messages
    define_routes

    def delete(guid)
      do_delete(find_guid_and_validate_access(:delete, guid))
    end

    def self.translate_validation_exception(e, attributes)
      Errors::ApiError.new_from_details("TestModelValidation", attributes["unique_value"])
    end
  end

  class TestModelManyToOnesController < RestController::ModelController
    define_attributes do
      to_one :test_model
    end

    define_messages
    define_routes
  end

  class TestModelManyToManiesController < RestController::ModelController
    define_attributes do
      to_many :test_model_second_levels
    end

    define_messages
    define_routes
  end

  class TestModelLinkOnliesController < RestController::ModelController
  end

  class TestModelSecondLevelsController < RestController::ModelController
  end
end
