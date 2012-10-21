module Quacky
  class UnexpectedArguments < ArgumentError;    end
  class UnsatisfiedExpectation < ArgumentError; end
  class MethodSignatureMismatch < ArgumentError;  end

  class Stub
    def initialize method, &block
      @method = method
      @return_block = block
    end

    def with *args
      @expected_args = args
      call_through *args
      self
    end

    def and_return value=nil, &block
      @return_value = value
      @return_block = block
      self
    end

    def call *args
      @called_args = args
      validate_expectation
      call_through *args

      if expected_args
        return_value if (called_args == expected_args)
      else
        return_value
      end
    end

    def validate_satisfaction!
      if expected_args 
        if called_args == expected_args
          true
        else
          raise UnsatisfiedExpectation
        end
      else
        was_called? || raise(UnsatisfiedExpectation, "Expected `#{@method.name}` to be called.")
      end
    end

    private
    attr_reader :called_args, :expected_args

    def was_called?
      !!called_args
    end

    def validate_expectation
      if expected_args && called_args != expected_args
        raise(
          Quacky::UnexpectedArguments, 
          "#{@method.name} was called with unexpected arguments: #{called_args.map(&:inspect).join ", "}. expected: #{expected_args.map(&:inspect).join ", "}"
        )
      end
    end

    def return_value
      return @return_value if @return_value
      @return_block.call if @return_block
    end

    def call_through *args
      begin
        @method.call *args
      rescue ArgumentError => e
        raise Quacky::MethodSignatureMismatch, "#{@method.receiver}##{@method.name} was called with the #{e.message}"
      end
    end
  end
end
