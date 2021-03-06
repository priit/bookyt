module BookingHelper
  def reference_types_as_collection
    types = [Invoice, Asset]
    types.inject({}) do |result, type|
      result[t_model(type)] = type.base_class
      result
    end
  end
end
