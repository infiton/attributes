# attributes
## Quick Start
```
class WithAttributes
  include Attributes

  attribute :without_default
  attribute :with_default, default: "default_value"

  def initialize(attrs={})
    attrs.each do |k,v|
      send("#{k}=", v) if respond_to?(k)
    end
  end
end

obj1 = WithAttributes.new
obj1.without_default # => nil
obj1.with_default # => "default_value"
obj1.attributes # => { without_default: nil, with_default: "default_value" }

obj2 = WithAttribute.new( without_default: "foo", with_default: "bar" )
obj2.without_default # => "foo"
obj2.with_default # => "bar"
obj2.attributes # => { without_default: "foo", with_default: "bar" }
```