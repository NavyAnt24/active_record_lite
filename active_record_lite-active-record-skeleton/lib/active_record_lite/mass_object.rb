class MassObject
  def self.my_attr_accessible(*attributes)
    @attributes = []
    attributes.each do |el|

      setter_method_name = el.to_s + "="
      define_method(setter_method_name) do |value|
        instance_variable_name = "@" + el.to_s
        @attributes << instance_variable_name.to_sym
        self.instance_variable_set(instance_variable_name, value)
      end

      getter_method_name = el.to_s
      define_method(getter_method_name) do
        self.instance_variable_get("@#{el}")
      end
    end
  end

  def self.attributes
    @attributes
  end

  def self.parse_all(results)
  end

  def initialize(params = {})
    params.each do |key, value|
      self.attributes.include?(key.to_sym)

  end
end