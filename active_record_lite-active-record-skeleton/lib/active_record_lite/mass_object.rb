class MassObject
  def self.my_attr_accessible(*attributes)
    @attributes = []
    attributes.each do |el|
      setter_method_name = el.to_s + "="
      @attributes << el.to_sym

      define_method("#{el}=") do |value|
        instance_variable_set("@#{el}".to_sym, value)
      end

      define_method(el.to_sym) do
        instance_variable_get("@#{el}".to_sym)
      end
    end
  end

  def self.attributes
    @attributes
  end

  def self.parse_all(results)
    results.map { |result| new(result) }
  end

  def initialize(params = {})
    params.each do |attr_name, value|
      if self.class.attributes.include?(attr_name.to_sym)
        self.send("#{attr_name}=", value)
      else
        raise "mass assignment to unregistered attribute #{attr_name}"
      end
    end
  end
end