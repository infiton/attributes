require 'minitest/autorun'
require_relative '../lib/attributes'

class TestAttributes
  include Attributes

  attribute :without_default
  attribute :with_default, default: "default_value"
  attribute :default_overriden, default: "not_overriden"
  attribute :array_with_lambda, default: -> { [] }
  attribute :array_without_lambda, default: []
  attribute :number_default, default: 0

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
      TestAttributes.attributes.must_equal [
        :without_default,
        :with_default,
        :default_overriden,
        :array_with_lambda,
        :array_without_lambda,
        :number_default
      ]
    end

    it 'has defaults' do
      defaults = TestAttributes.defaults
      defaults.select{|k,v| k != :array_with_lambda}.must_equal({
        with_default: "default_value",
        without_default: nil,
        default_overriden: "not_overriden",
        array_without_lambda: [],
        number_default: 0
      })

      defaults[:array_with_lambda].class.must_equal(Proc)
      defaults[:array_with_lambda].call.must_equal([])
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
      obj.attributes.must_equal({
        with_default: "default_value",
        without_default: nil,
        default_overriden: "not_overriden",
        array_with_lambda: [],
        array_without_lambda: [],
        number_default: 0
      })
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
      obj.attributes.must_equal({
        with_default: "set_with_default",
        without_default: "set_without_default",
        default_overriden: "not_overriden",
        array_with_lambda: [],
        array_without_lambda: [],
        number_default: 0
      })
    end

    it 'responds to attribute calls' do
      obj.without_default.must_equal "set_without_default"
      obj.with_default.must_equal "set_with_default"
    end
  end

  describe 'defaults use safe references' do
    it 'does not have the same default reference for different object' do
      first = TestAttributes.new
      array_default = first.array_without_lambda

      #modify the array default in place
      array_default << "fml"

      second = TestAttributes.new
      second.array_without_lambda.wont_equal(["fml"])
    end
  end

  describe 'inheritance' do
    describe 'the subclass' do
      it 'has the correct attributes' do
        SubTestAttributes.attributes.must_equal [
          :without_default,
          :with_default,
          :default_overriden,
          :array_with_lambda,
          :array_without_lambda,
          :number_default,
          :inherited_attribute
        ]
      end

      it 'has the correct defaults' do
        defaults = SubTestAttributes.defaults
        defaults.select{|k,v| k != :array_with_lambda}.must_equal({
          with_default: "default_value",
          without_default: nil,
          default_overriden: "overriden",
          array_without_lambda: [],
          number_default: 0,
          inherited_attribute: nil
        })

        defaults[:array_with_lambda].class.must_equal(Proc)
        defaults[:array_with_lambda].call.must_equal([])
      end
    end
  end
end