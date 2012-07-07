if defined? MiniTest
  module Quacky
    module MiniTest
      module Matchers
        def assert_quacks_like object, *modules
          modules.each do |a_module|
            Quacky::DuckTypeVerifier.new(a_module).verify! object
          end
        end
      end
    end
  end

  module Quacky
    alias :mock :double
    alias :class_mock :class_double

    module Expectations
      def expect method_name, return_value, with=[]
        should_receive(method_name).and_return(return_value).tap do |expectation|
          expectation.with(*with) unless with.empty?
        end
      end

      def stub method_name, return_value, with=[]
        quacky_stub(method_name).and_return(return_value).tap do |expectation|
          expectation.with(*with) unless with.empty?
        end
      end
    end
  end
end
