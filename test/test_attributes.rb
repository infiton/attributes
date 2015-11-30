require 'minitest/autorun'
require_relative '../lib/attributes'

class TestAttributes
  include Attributes

  attribute :without_default
  attribute :with_default, default: "default_value"
  attribute :default_overriden, default: "not_overriden"

  def initialize(attrs={})
    attrs.each do |k,v|
      send("#{k}=",v) if respond_to?(k)
    end
  end
end

class SubTestAttributes < TestAttributes
  attribute :default_overriden, default: "overriden"
  attribute :inherited_attribute
end

describe 'Attributes' do

  describe 'ClassMethods' do
    it 'has attributes' do
      TestAttributes.attributes.must_equal [:without_default,:with_default, :default_overriden]
    end

    it 'has defaults' do
      TestAttributes.defaults.must_equal({with_default: "default_value", without_default: nil, default_overriden: "not_overriden"})
    end

    describe 'attribute' do
      describe 'when passed a non-symbol' do
        it 'raises an ArgumentError' do
          -> { TestAttributes.class_eval { attribute 9 } }.must_raise ArgumentError
        end
      end
    end
  end

  describe 'when initialized without arguments' do
    let(:obj) { TestAttributes.new }

    it 'has the correct attributes' do
      obj.attributes.must_equal({with_default: "default_value", without_default: nil, default_overriden: "not_overriden"})
    end

    it 'responds to attribute calls' do
      obj.without_default.must_be_nil
      obj.with_default.must_equal "default_value"
    end

    it 'can set attributes' do
      obj.without_default = "set_value"
      obj.without_default.must_equal "set_value"
    end
  end

  describe 'when initialized with arguments' do
    let(:obj) { TestAttributes.new({without_default: "set_without_default", with_default: "set_with_default"}) }

    it 'has the correct attributes' do
      obj.attributes.must_equal({with_default: "set_with_default", without_default: "set_without_default", default_overriden: "not_overriden"})
    end

    it 'responds to attribute calls' do
      obj.without_default.must_equal "set_without_default"
      obj.with_default.must_equal "set_with_default"
    end
  end

  describe 'inheritance' do
    describe 'the subclass' do
      it 'has the correct attributes' do
        SubTestAttributes.attributes.must_equal [:without_default, :with_default, :default_overriden, :inherited_attribute]
      end

      it 'has the correct defaults' do
        SubTestAttributes.defaults.must_equal({with_default: "default_value", without_default: nil, default_overriden: "overriden", inherited_attribute: nil})
      end
    end
  end
end