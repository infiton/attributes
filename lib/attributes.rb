module Attributes
  def self.included(base)
    base.extend ClassMethods
    base.class_eval do
      @attributes = []
      @defaults = {}
    end
  end

  module ClassMethods
    def inherited(subclass)
      subclass.instance_variable_set("@attributes", attributes)
      subclass.instance_variable_set("@defaults", defaults)
    end

    def attribute(attribute, **opts)
      raise ArgumentError, "#{attribute} must be symbolizable" unless attribute.respond_to?(:to_sym)
      @attributes << attribute.to_sym unless @attributes.include?(attribute.to_sym)

      @defaults[attribute.to_sym] = opts[:default]

      define_method "#{attribute}" do
        instance_variable_get("@#{attribute}") || (
          defaults[attribute.to_sym].respond_to?(:call) ? defaults[attribute.to_sym].call : defaults[attribute.to_sym] 
        )
      end

      attr_writer attribute.to_sym
    end

    def attributes
      @attributes.clone
    end

    def defaults
      out = {}
      @defaults.each do |att, default|
        begin
          out[att] = default.clone
        rescue TypeError
          out[att] = default
        end
      end
      out
    end
  end

  def attributes
    self.class.attributes.inject({}) do |attrs, attribute|
      attrs[attribute] = send(attribute)
      attrs
    end
  end

  def defaults
    self.class.defaults
  end
end