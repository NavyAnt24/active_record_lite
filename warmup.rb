module Accessor
  def new_attr_accessor(*args)
    args.each do |el|
      setter_method_name = el.to_s + "="
      define_method(setter_method_name) do |value|
        instance_variable_name = "@" + el.to_s
        self.instance_variable_set(instance_variable_name, value)
      end

      getter_method_name = el.to_s
      define_method(getter_method_name) do
        self.instance_variable_get("@#{el}")
      end
    end
  end
end

class Cat
  extend Accessor

  new_attr_accessor :name, :color
end